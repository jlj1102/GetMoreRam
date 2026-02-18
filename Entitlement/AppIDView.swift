//
//  AppIDView.swift
//  Entitlement
//
//  Created by s s on 2025/3/15.
//
import SwiftUI

struct AppIDEditView : View {
    @StateObject var viewModel : AppIDModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    
    var body: some View {
        Form {
            Section {
                Button {
                    Task { await addIncreasedMemoryLimit() }
                } label: {
                    Text("增加内存上限")
                }
            }
            
            Section {
                Text(viewModel.result)
                    .font(.system(.subheadline, design: .monospaced))
            } header: {
                Text("服务器响应")
            }
        }
        .alert("错误", isPresented: $errorShow){
            Button("确定".loc, action: {
            })
        } message: {
            Text(errorInfo)
        }
        .navigationTitle(viewModel.bundleID)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func addIncreasedMemoryLimit() async {
        do {
            try await viewModel.addIncreasedMemory()
        } catch {
            errorInfo = error.localizedDescription
            errorShow = true
        }

    }
}


struct AppIDView : View {
    @StateObject var viewModel : AppIDViewModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(viewModel.appIDs, id: \.self) { appID in
                        NavigationLink {
                            AppIDEditView(viewModel: appID)
                        } label: {
                            Text(appID.bundleID)
                        }
                    }
                } header: {
                    Text("appids")
                }
                
                Section {
                    Button("刷新") {
                        Task { await refreshButtonClicked() }
                    }
                }
            }
            .alert("错误", isPresented: $errorShow){
                Button("确定".loc, action: {
                })
            } message: {
                Text(errorInfo)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func refreshButtonClicked() async {
        do {
            try await viewModel.fetchAppIDs()
        } catch {
            errorInfo = error.localizedDescription
            errorShow = true
        }
    }
}
