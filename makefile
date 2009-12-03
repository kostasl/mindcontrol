#This is the makefile for the entire OpticalMindControl Project.
#There are a number of executibles here. See the line marked Executables for a list of them all.
# At the moment this includes: 
#   CalibrateApparatus.exe -> Calibrates the position of the camera relative to the DLP. 
#   ClosedLoop.exe   ->   Run's the Apparatus in a closed loop, imaging while projecting (formerly RunApparatus)
#	SegmentFrame.exe -> 	Given a jpg file, this will find a worm, segment it and output lots of information about it.

#

#TailOpts =-pg # This generates output for a profiler such as gprof
TailOpts= -O2 #optimize the code	

#Location of directories
MyLibs=MyLibs
3rdPartyLibs=3rdPartyLibs
targetDir=bin
CVdir=C:/Progra~1/OpenCV
GIT=C:/Program\ Files/Git/bin/git

#Matlab Include directory for header files
MatlabIncDir= C:/Progra~1/MATLAB/R2009a/extern/include

#Matlab Compiled Libraries Directgory
MatlabLibsDir= C:/Progra~1/MATLAB/R2009a/extern/lib/win32/microsoft/

#OpenCV Include directories (for header files)
openCVincludes = -I$(CVdir)/cxcore/include -I$(CVdir)/otherlibs/highgui -I$(CVdir)/cv/include

# objects that I have written, in order of dependency. 
# e.g. Objects that depend on nothing go left.
#Objects that depend on other objects go right.
mylibraries=  tictoc.o version.o AndysComputations.o Talk2DLP.o Talk2Camera.o  AndysOpenCVLib.o Talk2Matlab.o TransformLib.o
WormSpecificLibs= WormAnalysis.o WriteOutWorm.o experiment.o

#3rd party statically linked objects
CVlibs=$(CVdir)/lib/cv.lib $(CVdir)/lib/highgui.lib $(CVdir)/lib/cxcore.lib
MatlabLibs=$(MatlabLibsDir)/libeng.lib $(MatlabLibsDir)/libmx.lib
3rdpartyobjects= $(3rdPartyLibs)/alp4basic.lib $(3rdPartyLibs)/tisgrabber.lib 

#All Objects
objects= main.o  $(mylibraries) $(WormSpecificLibs) $(3rdpartyobjects) $(CVlibs)  $(MatlabLibs)
calib_objects= calibrate.o $(mylibraries) $(3rdpartyobjects) $(CVlibs)  $(MatlabLibs)




#Executables
all : $(targetDir)/ClosedLoop.exe $(targetDir)/CalibrateApparatus.exe  version.o $(targetDir)/SegmentFrame.exe


$(targetDir)/CalibrateApparatus.exe : $(calib_objects)
	g++ -o $(targetDir)/CalibrateApparatus.exe $(calib_objects) $(TailOpts)

calibrate.o : calibrate.c $(3rdPartyLibs)/tisgrabber.h $(3rdPartyLibs)/TISGrabberGlobalDefs.h $(MyLibs)/Talk2DLP.h $(MyLibs)/Talk2Camera.h $(MatlabIncDir)/engine.h
	g++ -c -Wall calibrate.c -I"inc" -I$(MyLibs) $(openCVincludes) $(TailOpts) 

$(targetDir)/ClosedLoop.exe : $(objects)
	g++ -o $(targetDir)/ClosedLoop.exe $(objects) $(TailOpts)
	
	
main.o : main.cpp $(3rdPartyLibs)/tisgrabber.h $(3rdPartyLibs)/TISGrabberGlobalDefs.h $(MyLibs)/Talk2DLP.h $(MyLibs)/Talk2Camera.h  $(MyLibs)/TransformLib.h $(MatlabIncDir)/engine.h
	g++ -c -Wall main.cpp -I"inc" -I$(MyLibs) $(openCVincludes) $(TailOpts) 
	
Talk2DLP.o : $(MyLibs)/Talk2DLP.h $(MyLibs)/Talk2DLP.cpp 
	g++ -c  -Wall $(MyLibs)/Talk2DLP.cpp -I$(MyLibs) -I$(3rdPartyLibs) $(TailOpts)

Talk2Camera.o : $(MyLibs)/Talk2Camera.cpp $(MyLibs)/Talk2Camera.h \
$(3rdPartyLibs)/tisgrabber.h $(3rdPartyLibs)/TISGrabberGlobalDefs.h
	g++ -c -Wall $(MyLibs)/Talk2Camera.cpp -I$(3rdPartyLibs) -ITalk2Camera $(TailOpts)

AndysOpenCVLib.o : $(MyLibs)/AndysOpenCVLib.c $(MyLibs)/AndysOpenCVLib.h 
	g++ -c -v -Wall $(MyLibs)/AndysOpenCVLib.c $(openCVincludes) $(TailOpts)

Talk2Matlab.o : $(MyLibs)/Talk2Matlab.c $(MyLibs)/Talk2Matlab.h 
	g++ -c -v -Wall $(MyLibs)/Talk2Matlab.c $(openCVincludes) -I$(MatlabIncDir) $(TailOpts)

AndysComputations.o : $(MyLibs)/AndysComputations.c $(MyLibs)/AndysComputations.h
	g++ -c -v -Wall $(MyLibs)/AndysComputations.c  $(TailOpts)

TransformLib.o: $(MyLibs)/TransformLib.c
	g++ -c -v -Wall $(MyLibs)/TransformLib.c $(openCVincludes) $(TailOpts)
	
experiment.o: $(MyLibs)/experiment.c $(MyLibs)/experiment.h 
	g++ -c -v -Wall $(MyLibs)/experiment.c $ -I$(MyLibs) $(openCVincludes) $(TailOpts)

tictoc.o: $(MyLibs)/tictoc.cpp $(MyLibs)/tictoc.h 
	g++ -c -v -Wall $(MyLibs)/tictoc.cpp $ -I$(MyLibs)  $(TailOpts)


###### version.c & version.h
# note that version.c is generated at the very top. under "timestamp"
version.o : $(MyLibs)/version.c $(MyLibs)/version.h 
	g++ -c -Wall $(MyLibs)/version.c  -I$(MyLibs)  $(TailOpts)

#Trick so that git generates a version.c file
$(MyLibs)/version.c: FORCE 
	$(GIT) rev-parse HEAD | awk ' BEGIN {print "#include \"version.h\""} {print "const char * build_git_sha = \"" $$0"\";"} END {}' > $(MyLibs)/version.c
	date | awk 'BEGIN {} {print "const char * build_git_time = \""$$0"\";"} END {} ' >> $(MyLibs)/version.c	
		
FORCE:


###### SegmentFrame.exe
$(targetDir)/SegmentFrame.exe : $(objects)
	g++ -o $(targetDir)/SegmentFrame.exe $(objects) $(TailOpts) 

SegmentFrame.o : SegmentFrame.c $(myOpenCVlibraries) $(WormSpecificLibs) 
	g++ -c -Wall SegmentFrame.c -I$(MyLibs) $(openCVincludes) $(TailOpts)
	
WormAnalysis.o : $(MyLibs)/WormAnalysis.c $(MyLibs)/WormAnalysis.h $(myOpenCVlibraries) 
	g++ -c -Wall $(MyLibs)/WormAnalysis.c -I$(MyLibs) $(openCVincludes) $(TailOpts)

WriteOutWorm.o : $(MyLibs)/WormAnalysis.c $(MyLibs)/WormAnalysis.h $(MyLibs)/WriteOutWorm.c $(MyLibs)/WriteOutWorm.h $(myOpenCVlibraries) 
	g++ -c -Wall $(MyLibs)/WriteOutWorm.c -I$(MyLibs) $(openCVincludes) $(TailOpts)

$(MyLibs)/WriteOutWorm.c :  $(MyLibs)/version.h 


.PHONY: clean	
clean:
	rm -rf *.o 
	
	
#File List
#### DLP

#OpenCV Libraries have to be available on the environment path.

#fmteos.dll DLL for the encryption software that unlocks the DLL
#alp4basic.dll DLL control library for the DLP


#IMAGING SOURCE SOFTWARE to talk to Camera
#Tisgrabber.lib ImagingSource Statically Linked Library to Control Camera
#tisgrabber.h ImagingSource C wrapper Library header file
#tisgrabberGlobalDefs.h Imaging Source C wrpaper Global Definitions file
#tisgrabber.dll Imgaing Source Dynamically Linked Library

#### DLL's from Imaging Source
#DemoFilters.ftf
#ICFilterContainer.dll
#TIS_DShowLib07_vc71.dll
#TIS_UDSHL07_vc6.dll
#TIS_UDSHL07_vc6.lib
#TIS_UDSHL07_vc71.dll
#TIS_UDSHL07_vc71.lib
#TIS_UDSHL07_vc8.dll
#TIS_UDSHL07_vc8.lib
#dvdevice.vda
#mjpeg.tca
#stdfilters.ftf
#tisdcam.vda
#tisgrabber.dll
#tisgrabber.lib
#uvc_driver.vda
#vcc_vp.vda



### MATLAB
# engine.h    include file for matlab engine
# C:/Progra~1/MATLAB/R2008a/extern/lib/win32/microsoft/libeng.lib    Matlab's libraries to access the matlab engine
# C:/Progra~1/MATLAB/R2008a/extern/lib/win32/microsoft/libmx.lib   Matlab's Libraries to access the matlab engine

