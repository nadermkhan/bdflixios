// BDFlix/AboutView.swift
import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("BDFlix")
                        .font(.largeTitle.bold())

                    Text("Version 2.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider().padding(.horizontal, 40)

                    VStack(spacing: 6) {
                        Text("Developer")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Nader Mahbub Khan")
                            .font(.title3.bold())
                    }

                    Link(destination: URL(string: "https://www.facebook.com/nadermahbubkhan")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .font(.body)
                            Text("Facebook Profile")
                                .font(.body.bold())
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 40)
                    }

                    Divider().padding(.horizontal, 40)

                    VStack(spacing: 8) {
                        Text("Features")
                            .font(.headline)

                        FeatureItem(icon: "magnifyingglass", title: "Multi-Server Search",
                                    desc: "Search across 5 DHAKA-FLIX servers simultaneously")
                        FeatureItem(icon: "arrow.down.circle", title: "Built-in Downloader",
                                    desc: "Download files with progress tracking")
                        FeatureItem(icon: "folder", title: "Custom Save Location",
                                    desc: "Choose where to save your downloads")
                        FeatureItem(icon: "minus.circle", title: "Advanced Search",
                                    desc: "Use -word to exclude, \"phrase\" for exact match")
                    }

                    Divider().padding(.horizontal, 40)

                    Text("© 2026 All rights reserved.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Spacer().frame(height: 20)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 4)
    }
}
