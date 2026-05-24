import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: ArticleViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.forestDeep.ignoresSafeArea()
                List {
                    Section {
                        ForEach(StateFilter.allCases) { state in
                            Button {
                                viewModel.selectedState = state
                            } label: {
                                HStack {
                                    Image(systemName: state.icon)
                                        .frame(width: 26)
                                        .foregroundColor(.pine)
                                    Text(state.rawValue)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    if viewModel.selectedState == state {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.pine)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .listRowBackground(Color.forestDark)
                        }
                    } header: {
                        Label("Filter by State", systemImage: "mappin.circle")
                            .foregroundColor(.textMuted)
                    }

                    Section {
                        ForEach(SortOrder.allCases) { order in
                            Button {
                                viewModel.sortOrder = order
                            } label: {
                                HStack {
                                    Text(order.rawValue)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    if viewModel.sortOrder == order {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.pine)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .listRowBackground(Color.forestDark)
                        }
                    } header: {
                        Label("Sort by", systemImage: "arrow.up.arrow.down")
                            .foregroundColor(.textMuted)
                    }

                    Section {
                        Button(role: .destructive) {
                            viewModel.resetFilters()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Reset All Filters")
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.forestDark)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(.pine)
                }
            }
        }
        .colorScheme(.dark)
    }
}
