import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct FileInfo: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let modificationDate: Date
    
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var nameWithoutPrefix: String {
        // strip excluded strings
        var processedName = name
        if let range = name.range(of: "@[^ ]+ ", options: .regularExpression) {
            processedName = String(name[range.upperBound...])
        }
        return processedName
    }
}

struct ContentView: View {
    private let BUILD_VERSION = "1.0.5"
    @State private var folder1Path: String = ""
    @State private var folder2Path: String = ""
    @State private var files1: [FileInfo] = []
    @State private var files2: [FileInfo] = []
    @State private var differences: [String] = []
    @State private var exclusions: String = ""
    @State private var showingAbout = false
    
    private func processFileName(_ name: String) -> String {
        var processedName = name
        if !exclusions.isEmpty {
            let excludeStrings = exclusions
                .split(separator: ",", omittingEmptySubsequences: true)
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            for exclude in excludeStrings {
                // try exact match
                if processedName.localizedCaseInsensitiveContains(exclude) {
                    processedName = processedName.replacingOccurrences(
                        of: exclude,
                        with: "",
                        options: [.caseInsensitive, .diacriticInsensitive]
                    ).trimmingCharacters(in: .whitespaces)
                    print("DEBUG: Removed '\(exclude)' -> '\(processedName)'")
                }
            }
        }
        return processedName
    }
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        FolderDropZone(path: $folder1Path, title: "Original Stems")
                        Text(folder1Path.isEmpty ? "No folder selected" : folder1Path)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    
                    VStack(spacing: 8) {
                        FolderDropZone(path: $folder2Path, title: "New Stems")
                        Text(folder2Path.isEmpty ? "No folder selected" : folder2Path)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .frame(height: 150)
                
                TextField("Enter strings to exclude (comma-separated)", text: $exclusions)
                    .font(.system(size: 13))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
                    .cornerRadius(6)
                    .padding(.horizontal)
                
                Button(action: compareFolders) {
                    Text("Compare Folders")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.controlAccentColor))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(folder1Path.isEmpty || folder2Path.isEmpty)
                .opacity(folder1Path.isEmpty || folder2Path.isEmpty ? 0.5 : 1.0)
                
                ScrollView {
                    HStack(alignment: .top, spacing: 0) {
                        // left column
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Files only in original folder")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
                            
                            ForEach(Array(files1.filter { file in
                                !files2.contains { $0.nameWithoutPrefix == file.nameWithoutPrefix }
                            }.enumerated()), id: \.1.id) { index, file in
                                Text(file.name)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(VisualEffectView(material: index % 2 == 0 ? .contentBackground : .underPageBackground, blendingMode: .withinWindow))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // separator
                        Rectangle()
                            .fill(Color(NSColor.separatorColor))
                            .frame(width: 1)
                        
                        // right column
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Files only in new folder")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
                            
                            ForEach(Array(files2.filter { file in
                                !files1.contains { $0.nameWithoutPrefix == file.nameWithoutPrefix }
                            }.enumerated()), id: \.1.id) { index, file in
                                Text(file.name)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(VisualEffectView(material: index % 2 == 0 ? .contentBackground : .underPageBackground, blendingMode: .withinWindow))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow))
                .cornerRadius(8)
                .padding(.bottom, 32)
            }
            .padding(20)
            .frame(minWidth: 800, minHeight: 600)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Build \(BUILD_VERSION)")
                        .font(.system(size: 10))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .padding(8)
                        .onTapGesture {
                            NSApp.orderFrontStandardAboutPanel(nil)
                        }
                }
            }
        }
    }
    
    private func compareFolders() {
        print("DEBUG: Starting folder comparison with exclusion '\(exclusions)'")
        
        differences.removeAll()
        files1.removeAll()
        files2.removeAll()
        
        let url1 = URL(fileURLWithPath: folder1Path)
        let url2 = URL(fileURLWithPath: folder2Path)
        
        print("DEBUG: Comparing folders:")
        print("  Folder 1: \(url1.path)")
        print("  Folder 2: \(url2.path)")
        
        guard let contents1 = try? FileManager.default.contentsOfDirectory(at: url1, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]),
              let contents2 = try? FileManager.default.contentsOfDirectory(at: url2, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else {
            differences.append("Error reading folders")
            return
        }
        
        print("DEBUG: Found \(contents1.count) files in folder 1")
        print("DEBUG: Found \(contents2.count) files in folder 2")
        
        files1 = contents1.compactMap { url -> FileInfo? in
            let originalName = url.lastPathComponent
            let processedName = processFileName(originalName)
            print("DEBUG: Processing file '\(originalName)' -> '\(processedName)'")
            
            guard let resources = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                  let fileSize = resources.fileSize,
                  let modDate = resources.contentModificationDate else { return nil }
            return FileInfo(name: processedName, size: Int64(fileSize), modificationDate: modDate)
        }
        
        files2 = contents2.compactMap { url -> FileInfo? in
            guard let resources = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                  let fileSize = resources.fileSize,
                  let modDate = resources.contentModificationDate else { return nil }
            return FileInfo(name: processFileName(url.lastPathComponent), size: Int64(fileSize), modificationDate: modDate)
        }
        
        // compare counts
        if files1.count != files2.count {
            differences.append("Different number of files: \(files1.count) vs \(files2.count)")
            differences.append("")
        }
        
        // build name lookup tables
        let files1Dict = Dictionary(grouping: files1, by: { $0.nameWithoutPrefix })
        let files2Dict = Dictionary(grouping: files2, by: { $0.nameWithoutPrefix })
        
        let names1 = Set(files1Dict.keys)
        let names2 = Set(files2Dict.keys)
        
        // find files unique to each folder
        let uniqueToFolder1 = names1.subtracting(names2)
        let uniqueToFolder2 = names2.subtracting(names1)
        
        if !uniqueToFolder1.isEmpty {
            differences.append("Files only in original folder")
            uniqueToFolder1.sorted().forEach { name in
                if let file = files1Dict[name]?.first {
                    differences.append("  • \(file.name)")
                }
            }
            differences.append("")
        }
        
        if !uniqueToFolder2.isEmpty {
            differences.append("Files only in new folder")
            uniqueToFolder2.sorted().forEach { name in
                if let file = files2Dict[name]?.first {
                    differences.append("  • \(file.name)")
                }
            }
            differences.append("")
        }
        
        // check common files
        let commonNames = names1.intersection(names2)
        var hasDifferences = false
        
        if !commonNames.isEmpty {
            var prefixDifferences = false
            var sizeDifferences = false
            
            for name in commonNames.sorted() {
                if let file1 = files1Dict[name]?.first,
                   let file2 = files2Dict[name]?.first {
                    if file1.name != file2.name {
                        if !prefixDifferences {
                            differences.append("Files with different prefixes")
                            prefixDifferences = true
                        }
                        differences.append("  • \(file1.name)")
                        differences.append("    \(file2.name)")
                        hasDifferences = true
                    }
                    
                    // check sizes
                    if file1.size != file2.size {
                        if !sizeDifferences {
                            differences.append("Size mismatches")
                            sizeDifferences = true
                        }
                        differences.append("  • \(name)")
                        differences.append("    Original: \(file1.displaySize)")
                        differences.append("    New: \(file2.displaySize)")
                        hasDifferences = true
                    }
                }
            }
        }
        
        if !hasDifferences && uniqueToFolder1.isEmpty && uniqueToFolder2.isEmpty {
            differences.append("No differences found")
        }
    }
}

struct FolderDropZone: View {
    @Binding var path: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                
                VStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    Text("Drop folder here\nor click to select")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onTapGesture {
            selectFolder()
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil),
                      url.hasDirectoryPath else { return }
                
                DispatchQueue.main.async {
                    self.path = url.path
                }
            }
            return true
        }
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK {
            self.path = panel.url?.path ?? ""
        }
    }
}

struct AboutView: View {
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                        .resizable()
                        .frame(width: 96, height: 96)
                        .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("StemDiffer")
                            .font(.system(size: 24, weight: .regular))
                        
                        Text("Version 1.0.5")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                Spacer()
                
                Text("© 2024 Snackworld, Inc. All rights reserved.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                
                Button("Acknowledgements...") {
                    // TODO: Add acknowledgements
                }
                .font(.system(size: 13))
                .buttonStyle(.borderless)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 480, height: 280)
    }
} 