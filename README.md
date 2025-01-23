# stem folder differ

a simple macos app to compare two folders of audio stems, helping identify differences in file names, counts, and sizes.

## features

- drag and drop folder selection
- visual comparison of stem folders
- identifies:
  - different number of files
  - files present in one folder but not the other
  - size differences between files with the same name

## installation

### option 1: download the installer
1. download the latest release from the [releases page](https://github.com/getyoursnackon/stemdiff/releases)
2. double-click the downloaded `StemDiffer.pkg` file
3. follow the installer steps
4. launch StemDiffer from your Applications folder

### option 2: build from source
requirements:
- xcode 13.0 or later
- command line tools (run `xcode-select --install` in terminal)
- swift (comes with xcode, but run `xcode-select -p` to verify xcode path)

steps:
1. clone the repository:
```bash
git clone https://github.com/getyoursnackon/stemdiff.git
cd stemdiff
```

2. build and install:
```bash
./build.sh
```

## usage

1. launch the app
2. either drag and drop folders into the drop zones or click to select folders
3. click "compare folders" to see the differences
4. review the comparison results in the list below

## requirements

- macos 11.0 or later (big sur)
- xcode 13.0 or later (for development) 