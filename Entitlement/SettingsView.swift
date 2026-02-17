//
//  SettingsView.swift
//  Entitlement
//
//  Created by s s on 2025/3/14.
//

import SwiftUI
import StosSign

struct SettingsView: View {

    @State var email = ""
    @State var teamId = ""
    @StateObject var viewModel : LoginViewModel
    @EnvironmentObject private var sharedModel : SharedModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    

    var body: some View {
        Form {

            Section {
                if sharedModel.isLogin {
                    HStack {
                        Text("邮箱")
                        Spacer()
                        Text(email)
                    }
                    HStack {
                        Text("团队ID")
                        Spacer()
                        Text(teamId)
                    }
                } else {
                    Button("登入") {
                        viewModel.loginModalShow = true
                    }
                }
            } header: {
                Text("账户")
            }
            
            Section {
                HStack {
                    Text("Anisette服务器")
                    Spacer()
                    TextField("", text: $sharedModel.anisetteServerURL)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section {
                Button("清理钥匙串") {
                    cleanUp()
                }
            } footer: {
                Text("如果登录时报错，请尝试清理钥匙串，再重新打开软件。")
            }
        }
        .alert("错误", isPresented: $errorShow){
            Button("确定".loc, action: {
            })
        } message: {
            Text(errorInfo)
        }
        
        .sheet(isPresented: $viewModel.loginModalShow) {
            loginModal
        }
    }
    
    var loginModal: some View {
        NavigationView {
            Form {
                Section {
                    TextField("", text: $viewModel.appleID)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("Apple ID")
                }
                Section {
                    SecureField("", text: $viewModel.password)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("密码")
                }
                if viewModel.needVerificationCode {
                    Section {
                        TextField("", text: $viewModel.verificationCode)
                    } header: {
                        Text("二次验证码")
                    }
                }
                Section {
                    Button("继续") {
                        Task{ await loginButtonClicked() }
                    }
                }
                
                Section {
                    Text(viewModel.logs)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Text("调试日志")
                }
            }
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel) {
                        viewModel.loginModalShow = false
                    }
                }
            }
        }
        .onAppear {
            if let email = Keychain.shared.appleIDEmailAddress, let password = Keychain.shared.appleIDPassword {
                viewModel.appleID = email
                viewModel.password = password
            }
        }
    }
    
    func loginButtonClicked() async {
        do {
            if viewModel.needVerificationCode {
                viewModel.submitVerficationCode()
                return
            }
            
            let result = try await viewModel.authenticate()
            if result {
                viewModel.loginModalShow = false
                email = sharedModel.account!.appleID
                teamId = sharedModel.team!.identifier
            }
            
        } catch {
            errorInfo = error.localizedDescription
            errorShow = true
        }
    }
    
    func cleanUp() {
        Keychain.shared.adiPb = nil
        Keychain.shared.identifier = nil
        Keychain.shared.appleIDPassword = nil
        Keychain.shared.appleIDEmailAddress = nil
    }
    
}
