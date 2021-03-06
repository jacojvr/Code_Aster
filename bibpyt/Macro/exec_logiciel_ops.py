# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================

# person_in_charge: mathieu.courtois at edf.fr

"""
This module defines the EXEC_LOGICIEL operator
"""

import sys
import os
import os.path as osp
import re
import subprocess
from subprocess import PIPE
import tempfile
import traceback

import aster_core
from Utilitai.Utmess import UTMESS
from Utilitai.UniteAster import UniteAster
from code_aster.Cata.Commands import LIRE_MAILLAGE, PRE_GIBI


class CommandLine( object ):
    """Simple command line builder"""

    def __init__( self ):
        """Initialisation"""

    def build( self, cmd, shell=False ):
        """Return the command line to execute"""
        if shell:
            cmd = ' '.join(cmd)
        return cmd


class ExecProgram( object ):
    """Execute a program from Code_Aster

    Attributes:
    :step: the *etape* object
    :prog: the program to execute
    :args: the arguments passed to the program
    :shell: indicator to run the program through a shell
    :debug: debug flag
    :exitCodeMax: the maximum acceptable return code
    :cmdBuilder: object to build the command line
    """

    @staticmethod
    def factory(macro, **kwargs):
        """Factory that returns the object according to the arguments"""
        if kwargs['SALOME']:
            class_ = ExecSalomeScript
        elif kwargs['MAILLAGE']:
            fmt = kwargs['MAILLAGE']['FORMAT']
            if fmt not in ('GMSH', 'GIBI', 'SALOME'):
                UTMESS('F', 'EXECLOGICIEL0_2', valk=fmt)
            if fmt == 'SALOME':
                class_ = ExecSalome
            elif fmt == 'GMSH':
                class_ = ExecGmsh
            elif fmt == 'GIBI':
                class_ = ExecGibi
        else:
            class_ = ExecProgram
        return class_(macro)

    def __init__( self, step ):
        """Initialisation"""
        self.step = step

    def configure( self, kwargs ):
        """Pre-execution function, read the keywords"""
        self.prog = kwargs['LOGICIEL']
        self.args = list( kwargs['ARGUMENT'] or [] )
        self.shell = kwargs['SHELL'] == 'OUI'
        self.debug = kwargs['INFO'] == 2
        self.exitCodeMax = kwargs['CODE_RETOUR_MAXI']
        self.cmdBuilder = CommandLine()

    def execute( self ):
        """Execute the program"""
        self.executeCommand()

    def post( self ):
        """Execute a post-function"""

    def cleanUp( self ):
        """Cleanup function executed even if `execute` fails"""

    def executeCmdLine( self, cmd, capture, silent=False ):
        """Execute the command line.
        Return output, error and the exit code"""
        if self.debug or not silent:
            UTMESS('I', 'EXECLOGICIEL0_8',  valk=repr(cmd))
        options = { 'close_fds': True }
        if capture:
            options['stdout'] = PIPE
            options['stderr'] = PIPE
        process = subprocess.Popen(cmd, shell=self.shell, **options)
        output, error = process.communicate()
        status = process.returncode
        return output or '', error or '', status

    def executeCommand( self, capture=True, silent=False ):
        """Execute the program"""
        cmd = self.cmdBuilder.build( [self.prog] + self.args, self.shell )
        output, error, exitCode = self.executeCmdLine( cmd, capture, silent )
        ok = self.isOk( exitCode )
        # print the output
        if self.debug or not silent:
            UTMESS('I', 'EXECLOGICIEL0_11',
                   vali=[self.exitCodeMax, exitCode])
            if capture:
                UTMESS('I', 'EXECLOGICIEL0_9',  valk=output)
        # print error in debug mode or if it failed
        if (self.debug or not ok) and capture:
            UTMESS('I', 'EXECLOGICIEL0_10', valk=error, print_as='E')
        # error
        if not ok:
            UTMESS('F', 'EXECLOGICIEL0_3',
                   vali=[self.exitCodeMax, exitCode])

    def isOk( self, exitCode ):
        """Tell if the execution succeeded"""
        if self.exitCodeMax < 0:
            return True
        return exitCode <= self.exitCodeMax


class ExecMesher( ExecProgram ):
    """Execute a mesher

    fileIn --[ mesher ]--> fileOut --[ LIRE_MAILLAGE ]--> mesh

    Additional attributes:
    :fileIn: the data file used by the mesher
    :fileOut: the file that Code_Aster will read
    :format: format of the mesh that will be read by Code_Aster (not the
             format of fileOut)
    :uniteAster: UniteAster object
    """

    def configure( self, kwargs ):
        """Pre-execution function, read the keywords"""
        super(ExecMesher, self).configure( kwargs )
        self.uniteAster = UniteAster()
        self.fileIn = self.uniteAster.Nom( kwargs['MAILLAGE']['UNITE_GEOM'] )
        self.fileOut = None
        self.format = None

    def cleanUp( self ):
        """Cleanup function"""
        self.uniteAster.EtatInit()

    def post( self ):
        """Create the mesh object"""
        self.step.DeclareOut('mesh', self.step.sd)
        ulMesh = self.uniteAster.Unite(self.fileOut)
        assert ulMesh, \
            "file '{}' not associated to a logical unit".format(self.fileOut)
        mesh = LIRE_MAILLAGE(UNITE=ulMesh,
                             FORMAT=self.format,
                             INFO=2 if self.debug else 1)


class ExecSalome( ExecMesher ):
    """Execute a SALOME script from Code_Aster to create a med file
    A new SALOME session is started in background and stopped after
    the execution of the script.

    Additional attributes:
    :pid: port id of the SALOME session
    """

    def configure( self, kwargs ):
        """Pre-execution function, read the keywords"""
        super(ExecSalome, self).configure( kwargs )
        self.format = "MED"
        if len(self.args) != 1:
            UTMESS('F', 'EXECLOGICIEL0_1')
        self.fileOut = self.args[0]
        self.uniteAster.Libre(action='ASSOCIER', nom=self.fileOut)
        # start a SALOME session
        portFile = tempfile.NamedTemporaryFile(dir='.', suffix='.port').name
        self.prog = self.prog or osp.join(aster_core.get_option('repout'), 'salome')
        self.args = ['start', '-t', '--ns-port-log={}'.format(portFile)]
        # do not capture the output, it will block!
        self.executeCommand(capture=False, silent=True)
        self.pid = open(portFile, 'rb').read().strip()
        # prepare the main command
        self.args = ['shell', '-p', self.pid, self.fileIn]

    def cleanUp( self ):
        """Close the SALOME session"""
        self.args = ['shell', '-p', self.pid,
                     'killSalomeWithPort.py', 'args:{}'.format(self.pid)]
        self.executeCommand(silent=True)


class ExecGmsh( ExecMesher ):
    """Execute Gmsh from Code_Aster"""

    def configure( self, kwargs ):
        """Pre-execution function, read the keywords"""
        super(ExecGmsh, self).configure( kwargs )
        self.format = "MED"
        self.fileOut = tempfile.NamedTemporaryFile(dir='.', suffix='.med').name
        self.uniteAster.Libre(action='ASSOCIER', nom=self.fileOut)
        self.prog = self.prog or osp.join(aster_core.get_option('repout'), 'gmsh')
        self.args.extend( ['-3', '-format', 'med',
                           self.fileIn, '-o', self.fileOut] )


class ExecGibi( ExecMesher ):
    """Execute Gibi from Code_Aster"""

    def configure( self, kwargs ):
        """Pre-execution function, read the keywords"""
        super(ExecGibi, self).configure( kwargs )
        self.format = "ASTER"
        self.fileTmp = tempfile.NamedTemporaryFile(dir='.', suffix='.mgib').name
        self.fileOut = tempfile.NamedTemporaryFile(dir='.', suffix='.mail').name
        self.prog = self.prog or osp.join(aster_core.get_option('repout'), 'gibi')
        self.args.extend( [self.fileIn, self.fileTmp] )

    def post( self ):
        """Convert the mesh in ASTER format"""
        ulGibi = self.uniteAster.Libre(action='ASSOCIER', nom=self.fileTmp)
        ulMesh = self.uniteAster.Libre(action='ASSOCIER', nom=self.fileOut)
        PRE_GIBI(UNITE_GIBI=ulGibi,
                 UNITE_MAILLAGE=ulMesh)
        super(ExecGibi, self).post()


class ExecSalomeScript( ExecProgram ):
    """Execute a SALOME script using the `salome` launcher

    Additional attributes:
    :fileOut: the file that Code_Aster will read
    :format: format of the mesh that will be read by Code_Aster (not the
             format of fileOut)
    :uniteAster: UniteAster object
    """

    def configure( self, kwargs ):
        """Pre-execution function, read the keywords"""
        super(ExecSalomeScript, self).configure( kwargs )
        factKw = kwargs['SALOME']
        if os.environ.get('APPLI'):
            local = osp.join(os.environ['HOME'], os.environ['APPLI'],
                             'salome')
        else:
            local = osp.join(aster_core.get_option('repout'),
                             'salome')
        if not self.prog or factKw['MACHINE']:
            self.prog = local
        self.args.insert(0, 'shell')
        if factKw['MACHINE']:
            self.args.extend( ['-m', factKw['MACHINE']] )
            # suppose the path to salome is the same on the remote host
            # if LOGICIEL is not provided
            self.args.extend( ['-d', kwargs['LOGICIEL'] or local] )
            self.args.extend( ['-u', factKw['UTILISATEUR']] )
        self.args.extend( ['-p', str( factKw['PORT'] )] )
        # change NOM_PARA/VALE in the original script
        script = tempfile.NamedTemporaryFile(dir='.', suffix='.py').name
        writeSalomeScript( factKw['CHEMIN_SCRIPT'], script, factKw )
        self.args.append( script )
        # input and output files
        inputs = factKw['FICHIERS_ENTREE'] or []
        if inputs:
            self.args.append( 'args:' + ','.join(inputs) )
        outputs =  factKw['FICHIERS_SORTIE'] or []
        if outputs:
            self.args.append( 'out:' + ','.join(outputs) )
        safe_remove( *outputs )


def writeSalomeScript( orig, new, factKw ):
    """Create the SALOME script using a 'template'"""
    text = open( orig, 'rb' ).read()
    text = _textReplace( text, factKw['NOM_PARA'], factKw['VALE'] )
    text = _textReplaceNumb( text, 'INPUTFILE{}', factKw['FICHIERS_ENTREE'] )
    text = _textReplaceNumb( text, 'OUTPUTFILE{}', factKw['FICHIERS_SORTIE'] )
    open(new, 'wb').write( text )


def _textReplace( text, inStr, outStr ):
    """Replace input strings by output strings"""
    for orig, new in zip( inStr or [], outStr or [] ):
        text = re.sub(re.escape(orig), new, text)
    return text

def _textReplaceNumb( text, pattern, outStr ):
    """Replace input strings by output strings"""
    inStr = [ pattern.format(i + 1) for i in range(len(outStr or [])) ]
    return _textReplace( text, inStr, outStr )

def safe_remove( *args ):
    """Remove a file without failing if it does not exist"""
    for fileName in args:
        try:
            os.remove( fileName )
        except OSError:
            pass


def exec_logiciel_ops(self, **kwargs):
    """Execute a program, a script, a mesher... from Code_Aster"""
    import aster
    from Utilitai.Utmess import UTMESS

    self.set_icmd(1)

    action = ExecProgram.factory(self, **kwargs)
    try:
        action.configure( kwargs )
        action.execute()
        action.post()
    except aster.error, err:
        UTMESS('F', err.id_message, valk=err.valk,
               vali=err.vali, valr=err.valr)
    except Exception, err:
        trace = ''.join(traceback.format_tb(sys.exc_traceback))
        UTMESS('F', 'SUPERVIS2_5', valk=('EXEC_LOGICIEL', trace, str(err)))
    finally:
        action.cleanUp()
    return
