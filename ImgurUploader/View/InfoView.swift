//
//  InfoView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI
import WebUI
import WebKit

struct InfoView: View {
    @StateObject var viewModel = DropboxViewModel()
    
    var body: some View {
        List {
            NavigationLink(
                destination: TutorialView(),
                label: {
                    HStack {
                        Image(systemName: "hand.raised.fingers.spread")
                            .foregroundColor(.accentColor)
                        Text("Tutorial")
                    }
                }
            )
            
            NavigationLink(
                destination: TermsView(),
                label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                        Text("Terms Of Service")
                    }
                }
            )
            
            NavigationLink(
                destination: PrivacyPolicyView(),
                label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                        Text("Privacy Policy")
                    }
                }
            )
            
            Button {
                viewModel.logout()
            } label: {
                HStack {
                    Image(systemName: "figure.walk")
                    Text("Logout Dropbox")
                }
            }

        }
        .alert("Logout succeeded.", isPresented: $viewModel.isLoggedOut) {
            Button("OK") {
                
            }
        }
    }
}

struct TutorialView: View {
    var body: some View {
        TabView {
            ForEach(1...17, id: \.self) { item in
                Image("\(item)")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct TermsView: View {
    var body: some View {
        VStack {
            HTMLView(htmlString:
        """
        <body>
          <h1>Terms of Service</h1>
          <p>These Terms of Service (hereinafter referred to as "the Terms") set forth the conditions for using
            ImgurImageUploader (hereinafter referred to as "the Service") provided by our company. By using the Service, users
            are deemed to have agreed to these Terms.</p>

          <h2>Article 1 (Application)</h2>
          <p>These Terms apply to all relationships regarding the use of the Service between the users and our company.</p>

          <h2>Article 2 (Registration)</h2>
          <ol>
            <li>Users must agree to these Terms to use the Service.</li>
            <li>Registration is not required, and users can use the Service at any time.</li>
          </ol>

          <h2>Article 3 (Prohibited Actions)</h2>
          <p>Users must not engage in the following actions when using the Service:</p>
          <ul>
            <li>Actions that violate laws or public morals</li>
            <li>Actions related to criminal activities</li>
            <li>Actions that interfere with the operation of the Service</li>
            <li>Actions that infringe upon the intellectual property rights, portrait rights, privacy rights, honor, or other
              rights or interests of our company, other users, or third parties</li>
            <li>Other actions deemed inappropriate by our company</li>
          </ul>

          <h2>Article 4 (Responsibility for Uploads)</h2>
          <ol>
            <li>Users may upload images using the Service.</li>
            <li>Users are fully responsible for the images they upload.</li>
            <li>Our company does not guarantee the accuracy, completeness, reliability, or legality of the images uploaded by
              users.</li>
            <li>Our company is not responsible for any troubles or damages arising from the images uploaded by users.</li>
          </ol>

          <h2>Article 5 (Suspension of Service)</h2>
          <p>Our company may suspend or interrupt the provision of all or part of the Service without prior notice to users in
            the following cases:</p>
          <ul>
            <li>When performing maintenance or updates on the Service's systems</li>
            <li>When it becomes difficult to provide the Service due to force majeure such as fire, power outage, or natural
              disasters</li>
            <li>When computer or communication lines are interrupted due to accidents</li>
            <li>Other cases deemed difficult to provide the Service by our company</li>
          </ul>

          <h2>Article 6 (Disclaimer and Limitation of Liability)</h2>
          <ol>
            <li>Our company does not explicitly or implicitly guarantee that the Service is free of defects (including safety,
              reliability, accuracy, completeness, usefulness, suitability for specific purposes, security, etc., as well as
              defects, errors, bugs, and rights infringements).</li>
            <li>Our company is not responsible for any damages incurred by users due to the Service.</li>
          </ol>

          <h2>Article 7 (Changes to Terms)</h2>
          <p>Our company may change these Terms at any time without notice to users if deemed necessary. The revised Terms will
            take effect from the time they are posted within the Service.</p>

          <h2>Article 8 (Notifications and Communications)</h2>
          <p>Notifications or communications between users and our company will be made in a manner deemed appropriate by our
            company.</p>

          <h2>Article 9 (Prohibition of Assignment of Rights and Obligations)</h2>
          <p>Users may not transfer or pledge their position under the usage agreement or rights and obligations under these
            Terms to third parties without prior written consent from our company.</p>

          <h2>Article 10 (Governing Law and Jurisdiction)</h2>
          <ol>
            <li>The governing law for the interpretation of these Terms shall be Japanese law.</li>
            <li>In the event of a dispute related to the Service, the court having exclusive jurisdiction over our company's
              head office location shall be the agreed-upon court of jurisdiction.</li>
          </ol>

          <h2>Article 11 (Data Usage)</h2>
          <h3>Ad Data</h3>
          <p>Ad data is used for the following purposes:</p>
          <ul>
            <li>Third-party advertising</li>
            <li>Association with users' personal information</li>
            <li>Tracking purposes</li>
          </ul>

          <h3>Crash Data</h3>
          <p>Crash data is used for the following purpose:</p>
          <ul>
            <li>Analytics</li>
          </ul>

          <p>By using the Service, users are deemed to have agreed to the collection and use of ad data and crash data as
            described above.</p>

          <p>Last updated: October 2, 2024</p>


          <h2>Article 12 (Dropbox Integration)</h2>
          <ol>
            <li>The Service provides integration with Dropbox, allowing users to connect their Dropbox accounts for enhanced
              functionality.</li>
            <li>Our company does not collect or store any Dropbox account information (including but not limited to login
              credentials, account details, and personal information) or content information (including but not limited to file
              contents, file names, and metadata) through this integration.</li>
            <li>Users who choose to use the Dropbox integration feature do so at their own discretion, and our company maintains
              no access to or control over users' Dropbox accounts or content.</li>
            <li>The Dropbox integration feature is provided solely for the purpose of enhancing user convenience in utilizing
              the Service.</li>
          </ol>

          <p>Last updated: November 2, 2024</p>


        </body>
        """)
        }
        .padding()
    }
}


struct PrivacyPolicyView: View {
    var body: some View {
        VStack {
            HTMLView(htmlString:
        """
        <body>
          <h1>Privacy Policy</h1>
          <p>This Privacy Policy outlines the policy regarding the handling of personal information and other data by our
            service, ImgurImageUploader (hereinafter referred to as "the Service").</p>

          <h2>1. Collection of Personal Information</h2>
          <p>We do not directly collect personal information from users through the Service. However, we do collect certain
            non-personal data as described below.</p>

          <h2>2. Collection and Use of Non-Personal Data</h2>
          <h3>2.1 Ad Data</h3>
          <p>We collect and use ad data for the following purposes:</p>
          <ul>
            <li>Third-party advertising</li>
            <li>Association with users' personal information (managed by third-party ad providers)</li>
            <li>Tracking purposes</li>
          </ul>

          <h3>2.2 Crash Data</h3>
          <p>We collect crash data for the following purpose:</p>
          <ul>
            <li>Analytics to improve the Service</li>
          </ul>

          <p>By using the Service, users consent to the collection and use of ad data and crash data as described above.</p>

          <h2>3. Use of Data</h2>
          <p>The collected data is used to improve the Service, provide targeted advertising, and analyze usage patterns. We do
            not use this data for any other purposes beyond what is stated in this policy.</p>

          <h2>4. Provision of Data to Third Parties</h2>
          <p>We may share ad data with third-party advertising partners. Crash data is not shared with third parties unless
            required by law.</p>

          <h2>5. Security</h2>
          <p>While we do not collect personal information directly, we take reasonable precautions to protect the ad data and
            crash data we collect. However, no method of transmission over the Internet or electronic storage is 100% secure,
            and we cannot guarantee absolute security.</p>

          <h2>6. Children's Privacy</h2>
          <p>The Service is not intended for use by children under the age of 13. We do not knowingly collect data from children
            under 13.</p>

          <h2>7. Changes to This Privacy Policy</h2>
          <p>This Privacy Policy may be updated without prior notice. The revised Privacy Policy will take effect from the time
            it is posted within the Service. Users are encouraged to review this policy periodically.</p>

          <h2>8. Your Rights</h2>
          <p>Depending on your jurisdiction, you may have certain rights regarding your data, such as the right to access,
            correct, or delete your data. Please contact us using the information below to exercise these rights.</p>

          <h2>9. Dropbox Integration</h2>
          <p>While the Service provides integration with Dropbox for enhanced functionality, we want to clearly state that:</p>
          <ul>
            <li>We do not collect or store any Dropbox account information (including login credentials, account details, or
              personal information)</li>
            <li>We do not collect or store any Dropbox content information (including file contents, file names, or metadata)
            </li>
            <li>The integration is provided solely for user convenience and operates without our access to or storage of any
              Dropbox-related data</li>
          </ul>

          <p>Last updated: November 2, 2024</p>


        </body>
        """
            )
        }
        .padding()
    }
}

struct HTMLView: UIViewRepresentable {
    let htmlString: String
    
    // SwiftUIが初めてビューを作成するときに実行される
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    // ビューが変更されたときに実行される
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}


#Preview {
    InfoView()
}
