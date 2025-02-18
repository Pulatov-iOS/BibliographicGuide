//
//  SearchBarReportView.swift
//  BibliographicGuide
//
//  Created by Alexander on 20.07.23.
//

import SwiftUI

struct SearchBarReportView: View {
    
    @EnvironmentObject var reportViewModel: ReportViewModel

    @State private var textSearch = ""
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            TextField("Поиск ...", text: $textSearch)
                .padding(10)
                .padding(.horizontal, 25)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isSearching {
                            Button(action: {
                                self.textSearch = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isSearching = true
                }
            
            if isSearching {
                Button(action: {
                    self.isSearching = false
                    self.textSearch = ""
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Отмена")
                }
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .onChange(of: textSearch){ newValue in
            reportViewModel.fetchReportSearch(textSearch)
        }
        .onChange(of: isSearching){ newValue in
            if(newValue){
                reportViewModel.fetchReportSearch(textSearch)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}
