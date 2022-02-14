import SwiftUI
import SherlockDebugForms

/// NOTE: Each view that owns `SherlockForm` needs to conform to `SherlockView` protocol.
@MainActor
struct RootView: View, SherlockView
{
    /// NOTE:
    /// `searchText` is required for `SherlockView` protocol.
    /// This is the only requirement to define as `@State`, and pass it to `SherlockForm`.
    @State public var searchText: String = ""

    @AppStorage("username")
    private var username: String = "John Appleseed"

    /// Index of `Constant.languages`.
    @AppStorage("language")
    private var languageSelection: Int = 0

    @AppStorage("status")
    private var status = Constant.Status.online

    @AppStorage("low-power-mode")
    private var isLowPowerOn: Bool = false

    @AppStorage("speed")
    private var speed: Double = 1.0

    @AppStorage("font-size")
    private var fontSize: Double = 10

    @AppStorage("test-long-user-defaults")
    private var stringForTestingLongUserDefault: String = ""

    /// - Note:
    /// Attaching `.enableSherlockHUD(true)` to topmost view will allow using `showHUD`.
    /// See `SherlockHUD` module for more information.
    @Environment(\.showHUD)
    private var showHUD: (HUDMessage) -> Void

    var body: some View
    {
        // NOTE:
        // `SherlockForm` and `xxxCell` is where all the search magic is happening!
        // Just treat `SherlockForm` as a normal `Form`, and use `Section` and plain SwiftUI views accordingly.
        SherlockForm(searchText: $searchText) {
            // Simple form cells.
            Section {
                // Customized form cell using `vstackCell`.
                // NOTE: Combination of `SherlockForm` and `ContainerCell` is the secret of `keyword`-based searching.
                customVStackCell

                // Built-in form cells (using `hstackCell` internally).
                // See `FormCells` source directory for more info.
                textCell(title: "User", value: username)
                arrayPickerCell(title: "Language", selection: $languageSelection, values: Constant.languages)
                casePickerCell(title: "Status", selection: $status)
                toggleCell(title: "Low Power Mode", isOn: $isLowPowerOn)
                sliderCell(
                    title: "Speed",
                    value: $speed,
                    in: 0.5 ... 2.0,
                    step: 0.1,
                    maxFractionDigits: 1,
                    valueString: { "x\($0)" },
                    sliderLabel: { EmptyView() },
                    minimumValueLabel: { Image(systemName: "tortoise") },
                    maximumValueLabel: { Image(systemName: "hare") },
                    onEditingChanged: { print("onEditingChanged", $0) }
                )
                stepperCell(
                    title: "Font Size",
                    value: $fontSize,
                    in: 8 ... 24,
                    step: 1,
                    maxFractionDigits: 0,
                    valueString: { "\($0) pt" }
                )
            } header: {
                Text("Simple form cells")
            } footer: {
                if searchText.isEmpty {
                    Text("Tip: Long-press cells to copy!")
                }
            }

            // Navigation Link Cell (`navigationLinkCell`)
            Section {
                navigationLinkCell(
                    title: "UserDefaults",
                    destination: { UserDefaultsListView() }
                )
                navigationLinkCell(
                    title: "App Info",
                    destination: { AppInfoView() }
                )
                navigationLinkCell(
                    title: "Device Info",
                    destination: { DeviceInfoView() }
                )
                navigationLinkCell(title: "Custom Page", destination: {
                    CustomView()
                })
                navigationLinkCell(title: "Custom Page (Recursive)", destination: RootView.init)
            } header: {
                Text("Navigation Link Cell")
            } footer: {
                if searchText.isEmpty {
                    Text("Tip: Custom page (even this page) is just a plain SwiftUI View.")
                }
            }

            // Buttons (`buttonCell`)
            Section {
                buttonCell(
                    title: "Reset UserDefaults",
                    action: {
                        Helper.deleteUserDefaults()
                        showHUD(.init(message: "Finished resetting UserDefaults"))
                    }
                )

                buttonCell(
                    title: "Delete Caches",
                    action: {
                        try? Helper.deleteAllCaches()
                        showHUD(.init(message: "Finished deleting caches"))
                    }
                )

                if #available(iOS 15.0, *) {
                    // `buttonCell` with `confirmationDialog`.
                    buttonDialogCell(
                        title: "Delete All Contents",
                        dialogTitle: nil,
                        dialogButtons: { completion in
                            Button("Delete All Contents", role: .destructive) {
                                try? Helper.deleteAllFilesAndCaches()
                                showHUD(.init(message: "Finished deleting all contents"))
                                completion()
                            }
                            Button("Cancel", role: .cancel) {
                                print("Cancelled")
                                completion()
                            }
                        }
                    )
                }
                else {
                    buttonCell(title: "Delete All Contents", action: {
                        try? Helper.deleteAllFilesAndCaches()
                    })
                }
            } header: {
                Text("Buttons")
            } footer: {
                if searchText.isEmpty {
                    Text("Tip: Last button is ButtonDialog.")
                }
            }
        }
        .navigationTitle("Settings")
        // NOTE:
        // Use `formCellCopyable` here (as a wrapper of entire `SherlockForm`) to allow ALL `xxxCell`s to be copyable.
        // To Make each cell copyable one by one instead, call it as a wrapper of each form cell.
        .formCellCopyable(true)
        .onAppear {
            stringForTestingLongUserDefault = Array(repeating: Constant.loremIpsum, count: 10).joined(separator: "\n")
        }
    }

    /// Customized form cell using `vstackCell`.
    @ViewBuilder
    private var customVStackCell: some View
    {
        vstackCell(
            keywords: "Add", "your", "favorite", "keywords", "as much as possible", "Hello", "SherlockForms",
            copyableKeyValue: .init(key: "Hello SherlockForms!"),
            alignment: .center,
            content: {
                Text("🕵️‍♂️").font(.system(size: 48))
                Text("Hello SherlockForms!").font(.title)
            }
        )
            // NOTE:
            // `formCellContentModifier` allows to modify `cellContent` that wraps `vstackCell`'s `content`).
            //
            // This method may sometimes be needed for SwiftUI View method-chaining
            // to NOT start from "receiver" but from its `cellContent`.
            .formCellContentModifier { cellContent in
                cellContent
                    .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: 150)
                    .padding()
                    .onTapGesture {
                        print("Hello SherlockForms!")
                    }
            }
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        RootView()
    }
}
