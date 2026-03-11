#!/bin/bash
# generate_project.sh

mkdir -p BDFlix.xcodeproj

cat > BDFlix.xcodeproj/project.pbxproj << 'PBXPROJ'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A10000001 /* BDFlixApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000001; };
		A10000002 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000002; };
		A10000003 /* ServerInfo.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000003; };
		A10000004 /* FileResult.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000004; };
		A10000005 /* DownloadTask.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000005; };
		A10000006 /* SearchEngine.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000006; };
		A10000007 /* NetworkService.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000007; };
		A10000008 /* DownloadManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000008; };
		A10000009 /* ConnectionPool.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000009; };
		A10000010 /* SearchView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000010; };
		A10000011 /* DownloadsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000011; };
		A10000012 /* AboutView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000012; };
		A10000013 /* SearchBar.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000013; };
		A10000014 /* FileResultRow.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000014; };
		A10000015 /* DownloadRow.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000015; };
		A10000016 /* ProgressBarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000016; };
		A10000017 /* EmptyStateView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000017; };
		A10000018 /* AnimatedGradientBackground.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000018; };
		A10000019 /* SpinnerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000019; };
		A10000020 /* AppTheme.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000020; };
		A10000021 /* StringUtils.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000021; };
		A10000022 /* FileUtils.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000022; };
		A10000023 /* Formatters.swift in Sources */ = {isa = PBXBuildFile; fileRef = A20000023; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		A30000001 /* BDFlix.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = BDFlix.app; sourceTree = BUILT_PRODUCTS_DIR; };
		A20000001 /* BDFlixApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BDFlixApp.swift; sourceTree = "<group>"; };
		A20000002 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		A20000003 /* ServerInfo.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServerInfo.swift; sourceTree = "<group>"; };
		A20000004 /* FileResult.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileResult.swift; sourceTree = "<group>"; };
		A20000005 /* DownloadTask.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DownloadTask.swift; sourceTree = "<group>"; };
		A20000006 /* SearchEngine.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SearchEngine.swift; sourceTree = "<group>"; };
		A20000007 /* NetworkService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NetworkService.swift; sourceTree = "<group>"; };
		A20000008 /* DownloadManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DownloadManager.swift; sourceTree = "<group>"; };
		A20000009 /* ConnectionPool.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ConnectionPool.swift; sourceTree = "<group>"; };
		A20000010 /* SearchView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SearchView.swift; sourceTree = "<group>"; };
		A20000011 /* DownloadsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DownloadsView.swift; sourceTree = "<group>"; };
		A20000012 /* AboutView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AboutView.swift; sourceTree = "<group>"; };
		A20000013 /* SearchBar.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SearchBar.swift; sourceTree = "<group>"; };
		A20000014 /* FileResultRow.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileResultRow.swift; sourceTree = "<group>"; };
		A20000015 /* DownloadRow.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DownloadRow.swift; sourceTree = "<group>"; };
		A20000016 /* ProgressBarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProgressBarView.swift; sourceTree = "<group>"; };
		A20000017 /* EmptyStateView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EmptyStateView.swift; sourceTree = "<group>"; };
		A20000018 /* AnimatedGradientBackground.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AnimatedGradientBackground.swift; sourceTree = "<group>"; };
		A20000019 /* SpinnerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpinnerView.swift; sourceTree = "<group>"; };
		A20000020 /* AppTheme.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppTheme.swift; sourceTree = "<group>"; };
		A20000021 /* StringUtils.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StringUtils.swift; sourceTree = "<group>"; };
		A20000022 /* FileUtils.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileUtils.swift; sourceTree = "<group>"; };
		A20000023 /* Formatters.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Formatters.swift; sourceTree = "<group>"; };
		A20000024 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A40000001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A50000001 = {
			isa = PBXGroup;
			children = (
				A50000002 /* BDFlix */,
				A50000009 /* Products */,
			);
			sourceTree = "<group>";
		};
		A50000002 /* BDFlix */ = {
			isa = PBXGroup;
			children = (
				A20000001 /* BDFlixApp.swift */,
				A20000002 /* ContentView.swift */,
				A20000024 /* Info.plist */,
				A50000003 /* Models */,
				A50000004 /* Services */,
				A50000005 /* Views */,
				A50000008 /* Utilities */,
			);
			path = BDFlix;
			sourceTree = "<group>";
		};
		A50000003 /* Models */ = {
			isa = PBXGroup;
			children = (
				A20000003 /* ServerInfo.swift */,
				A20000004 /* FileResult.swift */,
				A20000005 /* DownloadTask.swift */,
				A20000006 /* SearchEngine.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		};
		A50000004 /* Services */ = {
			isa = PBXGroup;
			children = (
				A20000007 /* NetworkService.swift */,
				A20000008 /* DownloadManager.swift */,
				A20000009 /* ConnectionPool.swift */,
			);
			path = Services;
			sourceTree = "<group>";
		};
		A50000005 /* Views */ = {
			isa = PBXGroup;
			children = (
				A20000010 /* SearchView.swift */,
				A20000011 /* DownloadsView.swift */,
				A20000012 /* AboutView.swift */,
				A50000006 /* Components */,
				A50000007 /* Theme */,
			);
			path = Views;
			sourceTree = "<group>";
		};
		A50000006 /* Components */ = {
			isa = PBXGroup;
			children = (
				A20000013 /* SearchBar.swift */,
				A20000014 /* FileResultRow.swift */,
				A20000015 /* DownloadRow.swift */,
				A20000016 /* ProgressBarView.swift */,
				A20000017 /* EmptyStateView.swift */,
				A20000018 /* AnimatedGradientBackground.swift */,
				A20000019 /* SpinnerView.swift */,
			);
			path = Components;
			sourceTree = "<group>";
		};
		A50000007 /* Theme */ = {
			isa = PBXGroup;
			children = (
				A20000020 /* AppTheme.swift */,
			);
			path = Theme;
			sourceTree = "<group>";
		};
		A50000008 /* Utilities */ = {
			isa = PBXGroup;
			children = (
				A20000021 /* StringUtils.swift */,
				A20000022 /* FileUtils.swift */,
				A20000023 /* Formatters.swift */,
			);
			path = Utilities;
			sourceTree = "<group>";
		};
		A50000009 /* Products */ = {
			isa = PBXGroup;
			children = (
				A30000001 /* BDFlix.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A60000001 /* BDFlix */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A80000001 /* Build configuration list for PBXNativeTarget "BDFlix" */;
			buildPhases = (
				A70000001 /* Sources */,
				A40000001 /* Frameworks */,
				A70000002 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = BDFlix;
			productName = BDFlix;
			productReference = A30000001 /* BDFlix.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A90000001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1540;
				LastUpgradeCheck = 1540;
				TargetAttributes = {
					A60000001 = {
						CreatedOnToolsVersion = 15.4;
					};
				};
			};
			buildConfigurationList = A80000003 /* Build configuration list for PBXProject "BDFlix" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = A50000001;
			productRefGroup = A50000009 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A60000001 /* BDFlix */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A70000002 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A70000001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A10000001,
				A10000002,
				A10000003,
				A10000004,
				A10000005,
				A10000006,
				A10000007,
				A10000008,
				A10000009,
				A10000010,
				A10000011,
				A10000012,
				A10000013,
				A10000014,
				A10000015,
				A10000016,
				A10000017,
				A10000018,
				A10000019,
				A10000020,
				A10000021,
				A10000022,
				A10000023,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		B10000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGNING_REQUIRED = NO;
				CODE_SIGNING_ALLOWED = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = BDFlix/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 2.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.bdflix.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE = "";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		B10000002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGNING_REQUIRED = NO;
				CODE_SIGNING_ALLOWED = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = BDFlix/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 2.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.bdflix.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE = "";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		B10000003 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		B10000004 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A80000001 /* Build configuration list for PBXNativeTarget "BDFlix" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				B10000001 /* Debug */,
				B10000002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A80000003 /* Build configuration list for PBXProject "BDFlix" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				B10000003 /* Debug */,
				B10000004 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

	};
	rootObject = A90000001 /* Project object */;
}
PBXPROJ

mkdir -p BDFlix.xcodeproj/xcshareddata/xcschemes

cat > BDFlix.xcodeproj/xcshareddata/xcschemes/BDFlix.xcscheme << 'SCHEME'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1540"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "A60000001"
               BuildableName = "BDFlix.app"
               BlueprintName = "BDFlix"
               ReferencedContainer = "container:BDFlix.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
   </LaunchAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME

echo "Project generated successfully"
