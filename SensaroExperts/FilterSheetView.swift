import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: ForestryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // State filter
                Section {
                    ForEach(StateFilter.allCases) { state in
                        Button {
                            viewModel.selectedState = state
                        } label: {
                            HStack {
                                Image(systemName: state.icon)
                                    .frame(width: 26)
                                    .foregroundColor(.green)
                                Text(state.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedState == state {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Label("Filter by State", systemImage: "mappin.circle")
                }

                // Sort order
                Section {
                    ForEach(SortOrder.allCases) { order in
                        Button {
                            viewModel.sortOrder = order
                        } label: {
                            HStack {
                                Text(order.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.sortOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }

                // Reset
                Section {
                    Button(role: .destructive) {
                        viewModel.selectedState = .all
                        viewModel.sortOrder     = .relevance
                        viewModel.searchText    = ""
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset All Filters")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
    }
}
