# stem folder differ

a simple macos app to compare two folders of audio stems, helping identify differences in file names, counts, and sizes.

## about

stemdiff helps you compare two folders of audio stems to spot any differences. it's useful when:
- checking if all stems were exported correctly
- verifying if two versions of a project have the same stems
- finding stems that might have changed size or name

the app shows you:
- which files exist in one folder but not the other
- any size differences between matching files
- files with different prefixes

## features

- drag and drop folder selection
- visual comparison of stem folders
- identifies:
  - different number of files
  - files present in one folder but not the other
  - size differences between files with the same name

## building and installing

to build and install the app:

```bash
rm -rf .build && swift build -c release && mkdir -p StemDiffer.app/Contents/MacOS && cp .build/release/StemDiffer StemDiffer.app/Contents/MacOS/ && rm -rf /Applications/StemDiffer.app && cp -R StemDiffer.app /Applications/
```

this command will:
1. clean the build directory
2. build the app in release mode
3. create the app bundle structure
4. copy the built binary into the app bundle
5. install the app to your applications folder

## usage

1. launch the app
2. either drag and drop folders into the drop zones or click to select folders
3. click "compare folders" to see the differences
4. review the comparison results in the list below

## requirements

- macos 12.0 or later
- xcode 13.0 or later (for development) 