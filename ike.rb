class Ike < Formula
  desc ""
  homepage ""
  url "https://www.shrew.net/download/ike/ike-2.2.1-release.tbz2"
  version "2.2.1"
  sha256 "05c72f1ef1547818f5af367afa3f116f4b511a4a19ce723a22f8357a98ab7b57"

  depends_on "cmake" => :build
  # depends_on :x11 # if your formula requires any X11/XQuartz components
  
  patch :DATA

  def install
    system "cmake", ".", "-DQTGUI=YES", "-DNATT=YES", "-DQT_QMAKE_EXECUTABLE=/usr/local/bin/qmake",  *std_cmake_args
    system "make", "install" # if this fails, try separate make/make install steps
    frameworks.install_symlink Dir["#prefix/Frameworks/*.framework"] 
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test ike`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end

  def caveats
    text = <<-EOS.undent
      sudo ln -s /usr/local/Cellar/ike/2.2.1/Frameworks/ShrewSoftIke.framework /Library/Frameworks
      sudo ln -s /usr/local/Cellar/ike/2.2.1/Frameworks/ShrewSoftIp.framework /Library/Frameworks
      sudo ln -s /usr/local/Cellar/ike/2.2.1/Frameworks/ShrewSoftPfkey.framework /Library/Frameworks
      sudo ln -s /usr/local/Cellar/ike/2.2.1/Frameworks/ShrewSoftIdb.framework /Library/Frameworks
      sudo ln -s /usr/local/Cellar/ike/2.2.1/Frameworks/ShrewSoftLog.framework /Library/Frameworks
      sudo ln -s /usr/local/Cellar/ike/2.2.1/Frameworks/ShrewSoftIth.framework /Library/Frameworks
    EOS
    text
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 8170453..fd0c5a1 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -42,12 +42,14 @@ subdirs(
 set(
 	SEARCH_INC
 	/usr/local/include
-	/usr/include )
+	/usr/include
+	/usr/local/opt/openssl/include )
 
 set(
 	SEARCH_LIB
 	/usr/local/lib
-	/usr/lib )
+	/usr/lib
+	/usr/local/opt/openssl/lib )
 
 set(
 	SEARCH_BIN
@@ -84,13 +84,6 @@ endif( APPLE )
 # Path Option Checks
 #
 
-if( NOT EXISTS ${CMAKE_INSTALL_PREFIX} )
-
-	set(
-		CMAKE_INSTALL_PREFIX "/usr" )
-
-endif( NOT EXISTS ${CMAKE_INSTALL_PREFIX} )
-
 message(
 	STATUS 
 	"Using install prefix ${CMAKE_INSTALL_PREFIX} ..." )
@@ -102,17 +104,8 @@ if( ETCDIR )
 
 else( ETCDIR )
 
-	if( EXISTS ${CMAKE_INSTALL_PREFIX}/etc )
-
-		set(
-			PATH_ETC "${CMAKE_INSTALL_PREFIX}/etc" )
-
-	else( EXISTS ${CMAKE_INSTALL_PREFIX}/etc )
-		
-		set(
-			PATH_ETC "/etc" )
-
-	endif( EXISTS ${CMAKE_INSTALL_PREFIX}/etc )
+	set(
+		PATH_ETC "${CMAKE_INSTALL_PREFIX}/etc" )
 
 endif( ETCDIR )
 
@@ -129,17 +122,8 @@ if( BINDIR )
 
 else( BINDIR )
 
-	if( EXISTS ${CMAKE_INSTALL_PREFIX}/bin )
-
-		set(
-			PATH_BIN "${CMAKE_INSTALL_PREFIX}/bin" )
-
-	else( EXISTS ${CMAKE_INSTALL_PREFIX}/bin )
-
-		set(
-			PATH_LIB "/usr/bin" )
-
-	endif( EXISTS ${CMAKE_INSTALL_PREFIX}/bin )
+	set(
+		PATH_BIN "${CMAKE_INSTALL_PREFIX}/bin" )
 
 endif( BINDIR )
 
@@ -156,17 +140,8 @@ if( SBINDIR )
 
 else( SBINDIR )
 
-	if( EXISTS ${CMAKE_INSTALL_PREFIX}/sbin )
-
-		set(
-			PATH_SBIN "${CMAKE_INSTALL_PREFIX}/sbin" )
-
-	else( EXISTS ${CMAKE_INSTALL_PREFIX}/sbin )
-
-		set(
-			PATH_SBIN "/usr/sbin" )
-
-	endif( EXISTS ${CMAKE_INSTALL_PREFIX}/sbin )
+	set(
+		PATH_SBIN "${CMAKE_INSTALL_PREFIX}/sbin" )
 
 endif( SBINDIR )
 
@@ -183,17 +158,8 @@ if( LIBDIR )
 
 else( LIBDIR )
 
-	if( EXISTS ${CMAKE_INSTALL_PREFIX}/lib )
-
-		set(
-			PATH_LIB "${CMAKE_INSTALL_PREFIX}/lib" )
-
-	else( EXISTS ${CMAKE_INSTALL_PREFIX}/lib )
-
-		set(
-			PATH_LIB "/usr/lib" )
-
-	endif( EXISTS ${CMAKE_INSTALL_PREFIX}/lib )
+	set(
+		PATH_LIB "${CMAKE_INSTALL_PREFIX}/lib" )
 
 endif( LIBDIR )
 
@@ -210,23 +176,8 @@ if( MANDIR )
 
 else( MANDIR )
 
-	find_path(
-		PATH_MAN
-		NAMES "man"
-		PATHS ${SEARCH_SYS}
-		NO_DEFAULT_PATH )
-
-	if( PATH_MAN )
-
-		set(
-			PATH_MAN "${PATH_MAN}/man" )
-
-	else( PATH_MAN )
-
-		set(
-			PATH_MAN "${CMAKE_INSTALL_PREFIX}/man" )
-
-	endif( PATH_MAN )
+	set(
+		PATH_MAN "${CMAKE_INSTALL_PREFIX}/man" )
 
 endif( MANDIR )
 
diff --git a/source/iked/CMakeLists.txt b/source/iked/CMakeLists.txt
index 2e41586..1f4b2cf 100644
--- a/source/iked/CMakeLists.txt
+++ b/source/iked/CMakeLists.txt
@@ -18,7 +18,8 @@ include_directories(
 	${IKE_SOURCE_DIR}/source/libip
 	${IKE_SOURCE_DIR}/source/liblog
 	${IKE_SOURCE_DIR}/source/libpfk
-	${INC_KERNEL_DIR} )
+	${INC_KERNEL_DIR}
+        ${PATH_INC_CRYPTO} )
 
 link_directories(
 	${IKE_SOURCE_DIR}/source/libike
diff --git a/source/libike/CMakeLists.txt b/source/libike/CMakeLists.txt
index 5331136..0336c40 100644
--- a/source/libike/CMakeLists.txt
+++ b/source/libike/CMakeLists.txt
@@ -15,7 +15,8 @@ include_directories(
         ${IKE_SOURCE_DIR}/source/libidb
         ${IKE_SOURCE_DIR}/source/libith
         ${IKE_SOURCE_DIR}/source/liblog
-        ${IKE_SOURCE_DIR}/source/libip )
+        ${IKE_SOURCE_DIR}/source/libip
+        ${PATH_INC_CRYPTO} )
 
 add_library(
 	ss_ike SHARED
diff --git a/CMakeLists.txt b/CMakeLists.txt
index fd0c5a1..a7a74d9 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
diff --git a/source/libidb/CMakeLists.txt b/source/libidb/CMakeLists.txt
index e141e3f..e6ba9ce 100644
--- a/source/libidb/CMakeLists.txt
+++ b/source/libidb/CMakeLists.txt
@@ -47,4 +47,4 @@ endif( APPLE )
 install(
 	TARGETS ss_idb
 	LIBRARY DESTINATION ${PATH_LIB}
-	FRAMEWORK DESTINATION "/Library/Frameworks" )
+	FRAMEWORK DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks" )
diff --git a/source/libike/CMakeLists.txt b/source/libike/CMakeLists.txt
index 0336c40..2445f67 100644
--- a/source/libike/CMakeLists.txt
+++ b/source/libike/CMakeLists.txt
@@ -56,5 +56,5 @@ endif( APPLE )
 install(
 	TARGETS ss_ike
 	LIBRARY DESTINATION ${PATH_LIB}
-	FRAMEWORK DESTINATION "/Library/Frameworks" )
+	FRAMEWORK DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks" )
 
diff --git a/source/libip/CMakeLists.txt b/source/libip/CMakeLists.txt
index b7d3eb2..a1a7ffa 100644
--- a/source/libip/CMakeLists.txt
+++ b/source/libip/CMakeLists.txt
@@ -53,4 +53,4 @@ endif( APPLE )
 install(
 	TARGETS ss_ip
 	LIBRARY DESTINATION ${PATH_LIB}
-	FRAMEWORK DESTINATION "/Library/Frameworks" )
+	FRAMEWORK DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks" )
diff --git a/source/libith/CMakeLists.txt b/source/libith/CMakeLists.txt
index 1f4f6f1..140ab02 100644
--- a/source/libith/CMakeLists.txt
+++ b/source/libith/CMakeLists.txt
@@ -48,4 +48,4 @@ endif( APPLE )
 install(
 	TARGETS ss_ith
 	LIBRARY DESTINATION ${PATH_LIB}
-	FRAMEWORK DESTINATION "/Library/Frameworks" )
+	FRAMEWORK DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks" )
diff --git a/source/liblog/CMakeLists.txt b/source/liblog/CMakeLists.txt
index d0b619c..73e3ed7 100644
--- a/source/liblog/CMakeLists.txt
+++ b/source/liblog/CMakeLists.txt
@@ -43,5 +43,5 @@ endif( APPLE )
 install(
 	TARGETS ss_log
 	LIBRARY DESTINATION ${PATH_LIB}
-	FRAMEWORK DESTINATION "/Library/Frameworks" )
+	FRAMEWORK DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks" )
 
diff --git a/source/libpfk/CMakeLists.txt b/source/libpfk/CMakeLists.txt
index ffca9af..9ba547a 100644
--- a/source/libpfk/CMakeLists.txt
+++ b/source/libpfk/CMakeLists.txt
@@ -46,5 +46,5 @@ endif( APPLE )
 install(
 	TARGETS ss_pfk
 	LIBRARY DESTINATION ${PATH_LIB}
-	FRAMEWORK DESTINATION "/Library/Frameworks" )
+	FRAMEWORK DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks" )
 
diff --git a/source/libqt/CMakeLists.txt b/source/libqt/CMakeLists.txt
index 9cf8087..95c210c 100644
--- a/source/libqt/CMakeLists.txt
+++ b/source/libqt/CMakeLists.txt
@@ -13,29 +13,29 @@ if( APPLE )
 
 	install(
 		DIRECTORY "${QT_LIBRARY_DIR}/QtCore.framework/Contents"
-		DESTINATION "/Library/Frameworks/ShrewSoftQtCore.framework"
+		DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtCore.framework"
 		COMPONENT Runtime )
 
 	install(
 		FILES "${QT_LIBRARY_DIR}/QtCore.framework/Versions/4/QtCore"
-		DESTINATION "/Library/Frameworks/ShrewSoftQtCore.framework/Versions/4"
+		DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtCore.framework/Versions/4"
 		RENAME "ShrewSoftQtCore"
 		COMPONENT Runtime )
 
 	install(
 		CODE "execute_process( COMMAND \"ln\" -s
 			4
-			/Library/Frameworks/ShrewSoftQtCore.framework/Versions/Current )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtCore.framework/Versions/Current )" )
 
 	install(
 		CODE "execute_process( COMMAND \"ln\" -s
 			Versions/4/Resources
-			/Library/Frameworks/ShrewSoftQtCore.framework/Resources )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtCore.framework/Resources )" )
 
 	install(
 		CODE "execute_process( COMMAND \"install_name_tool\" -id
 			ShrewSoftQtCore.framework/Versions/4/ShrewSoftQtCore
-			/Library/Frameworks/ShrewSoftQtCore.framework/Versions/4/ShrewSoftQtCore )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtCore.framework/Versions/4/ShrewSoftQtCore )" )
 
 	# QtGui Private Library Framework
 
@@ -46,34 +46,34 @@ if( APPLE )
 
 	install(
 		FILES "${QT_LIBRARY_DIR}/QtGui.framework/Versions/4/QtGui"
-		DESTINATION "/Library/Frameworks/ShrewSoftQtGui.framework/Versions/4"
+		DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtGui.framework/Versions/4"
 		RENAME "ShrewSoftQtGui"
 		COMPONENT Runtime )
 
 	install(
 		CODE "execute_process( COMMAND \"ln\" -s
 			4
-			/Library/Frameworks/ShrewSoftQtGui.framework/Versions/Current )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtGui.framework/Versions/Current )" )
 
 	install(
 		CODE "execute_process( COMMAND \"ln\" -s
 			Versions/4/Resources
-			/Library/Frameworks/ShrewSoftQtGui.framework/Resources )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtGui.framework/Resources )" )
 
 	install(
 		DIRECTORY "${QT_LIBRARY_DIR}/QtGui.framework/Versions/4/Resources"
-		DESTINATION "/Library/Frameworks/ShrewSoftQtGui.framework/Versions/4"
+		DESTINATION "${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtGui.framework/Versions/4"
 		COMPONENT Runtime )
 
 	install(
 		CODE "execute_process( COMMAND \"install_name_tool\" -id
 			ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui
-			/Library/Frameworks/ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui )" )
 
 	install(
 		CODE "execute_process( COMMAND \"install_name_tool\" -change
 			${QT_LIBRARY_DIR}/QtCore.framework/Versions/4/QtCore
 			ShrewSoftQtCore.framework/Versions/4/ShrewSoftQtCore
-			/Library/Frameworks/ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui )" )
+			${CMAKE_INSTALL_PREFIX}/Frameworks/ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui )" )
 
 endif( APPLE )
diff --git a/source/qikea/CMakeLists.txt b/source/qikea/CMakeLists.txt
index 98682e2..81087d8 100644
--- a/source/qikea/CMakeLists.txt
+++ b/source/qikea/CMakeLists.txt
@@ -106,7 +106,7 @@ endif( APPLE )
 install(
 	TARGETS qikea
 	RUNTIME	DESTINATION bin
-	BUNDLE DESTINATION "/Applications" )
+	BUNDLE DESTINATION "${CMAKE_INSTALL_PREFIX}/Applications" )
 
 install(
 	FILES qikea.1
@@ -116,7 +116,7 @@ if( APPLE )
 
 #	set(
 #		MACOSX_BUNDLE_DEST_DIR
-#		"/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app" )
+#		"${CMAKE_INSTALL_PREFIX}/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app" )
 
 #	set(
 #		MACOSX_QTPLUGINS_DEST_DIR
@@ -139,12 +139,12 @@ if( APPLE )
 		CODE "execute_process( COMMAND \"install_name_tool\" -change
 			${QT_LIBRARY_DIR}/QtCore.framework/Versions/4/QtCore
 			ShrewSoftQtCore.framework/Versions/4/ShrewSoftQtCore
-			\"/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
+			\"${CMAKE_INSTALL_PREFIX}/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
 
 	install(
 		CODE "execute_process( COMMAND \"install_name_tool\" -change
 			${QT_LIBRARY_DIR}/QtGui.framework/Versions/4/QtGui
 			ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui
-			\"/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
+			\"${CMAKE_INSTALL_PREFIX}/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
 
 endif( APPLE )
diff --git a/source/qikec/CMakeLists.txt b/source/qikec/CMakeLists.txt
index 4a6f1b4..bb1fdab 100644
--- a/source/qikec/CMakeLists.txt
+++ b/source/qikec/CMakeLists.txt
@@ -104,7 +104,7 @@ endif( APPLE )
 install(
 	TARGETS qikec
 	RUNTIME	DESTINATION bin
-	BUNDLE DESTINATION "/Applications" )
+	BUNDLE DESTINATION "${CMAKE_INSTALL_PREFIX}/Applications" )
 
 install(
 	FILES qikec.1
@@ -137,12 +137,12 @@ if( APPLE )
 		CODE "execute_process( COMMAND \"install_name_tool\" -change
 			${QT_LIBRARY_DIR}/QtCore.framework/Versions/4/QtCore
 			ShrewSoftQtCore.framework/Versions/4/ShrewSoftQtCore
-			\"/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
+			\"${CMAKE_INSTALL_PREFIX}/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
 
 	install(
 		CODE "execute_process( COMMAND \"install_name_tool\" -change
 			${QT_LIBRARY_DIR}/QtGui.framework/Versions/4/QtGui
 			ShrewSoftQtGui.framework/Versions/4/ShrewSoftQtGui
-			\"/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
+			\"${CMAKE_INSTALL_PREFIX}/Applications/${MACOSX_BUNDLE_BUNDLE_NAME}.app/Contents/MacOS/${MACOSX_BUNDLE_BUNDLE_NAME}\" )" )
 
 endif( APPLE )
