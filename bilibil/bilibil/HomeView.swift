//
//  HomeView.swift
//  bilibil
//
//  Created by SOSD_M1_2 on 2025/4/25.
//

import SwiftUI

struct HomeView: View {
    @State private var dbManager = DatabaseManager()
        @State private var videos: [(id: Int, name: String, coverImage: String)] = []
        @State private var selectedTab = 1
        @State private var offset: CGFloat = 0
        
        private let tabs = [
            (id: 0, name: "直播"),
            (id: 1, name: "推荐"),
            (id: 2, name: "热门"),
            (id: 3, name: "动画"),
            (id: 4, name: "影视")
        ]
        
        private let sampleVideos = [
            (name: "SwiftUI入门教程", coverImage: "swift"),
            (name: "iOS开发实战", coverImage: "iphone"),
            (name: "SQLite数据库使用", coverImage: "database"),
            (name: "B站首页仿制", coverImage: "play.rectangle"),
            (name: "WWDC最新技术", coverImage: "applelogo")
        ]
        
        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // 搜索栏按钮 - 现在作为 NavigationLink
                    NavigationLink(destination: SearchView(dbManager: dbManager)) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("搜索视频")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 顶部导航栏分区 (保持不变)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(tabs, id: \.id) { tab in
                                VStack {
                                    Text(tab.name)
                                        .font(.system(size: 16, weight: selectedTab == tab.id ? .bold : .regular))
                                        .foregroundColor(selectedTab == tab.id ? .black : .gray)
                                    
                                    if selectedTab == tab.id {
                                        Color.blue
                                            .frame(height: 3)
                                            .cornerRadius(1.5)
                                    } else {
                                        Color.clear
                                            .frame(height: 3)
                                    }
                                }
                                .frame(width: 60)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = tab.id
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .frame(height: 40)
                    .background(Color(.systemBackground))
                    
                    // 内容区域 (保持不变)
                    TabView(selection: $selectedTab) {
                        LiveContentView().tag(0)
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(videos, id: \.id) { video in
                                    NavigationLink(destination: VideoDetailView(video: video)) {
                                        VideoCardView(
                                            title: video.name,
                                            author: "UP主 \(video.id)",
                                            views: "\(Int.random(in: 1000...10000))观看",
                                            coverImage: video.coverImage
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                        .tag(1)
                        
                        HotContentView().tag(2)
                        AnimeContentView().tag(3)
                        MovieContentView().tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: UIScreen.main.bounds.height - 240)
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { offset = $0.translation.width }
                            .onEnded { handleSwipe($0) }
                    )
                }
                .navigationTitle("首页")
                .navigationBarHidden(true)
                .onAppear {
                    if dbManager.getAllVideos().isEmpty {
                        addSampleVideos()
                    }
                    refreshVideos()
                }
            }
        }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        withAnimation {
            if value.translation.width < -100 && selectedTab < tabs.count - 1 {
                selectedTab += 1
            } else if value.translation.width > 100 && selectedTab > 0 {
                selectedTab -= 1
            }
            offset = 0
        }
    }
    
    private func addSampleVideos() {
        for video in sampleVideos {
            dbManager.addVideo(name: video.name, coverImage: video.coverImage)
        }
    }
    
    private func refreshVideos() {
        videos = dbManager.getAllVideos()
    }
}

// 其他分区内容占位视图
struct LiveContentView: View {
    var body: some View {
        VStack {
            Text("直播内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct HotContentView: View {
    var body: some View {
        VStack {
            Text("热门内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct AnimeContentView: View {
    var body: some View {
        VStack {
            Text("动画内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct MovieContentView: View {
    var body: some View {
        VStack {
            Text("影视内容区域")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct VideoCardView: View {
    let title: String
    let author: String
    let views: String
    let coverImage: String
    
    var body: some View {
        VStack(alignment: .leading) {
            // 视频缩略图 - 使用SF Symbol或系统图片
            Image(systemName: coverImage)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            
            // 视频信息
            HStack(alignment: .top) {
                // UP主头像
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(author)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(views)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 8)
    }
}


struct SearchView: View {
    @ObservedObject var dbManager: DatabaseManager
    @State private var searchText = ""
    @State private var searchResults: [(id: Int, name: String, coverImage: String)] = []
    @State private var isSearching = false
    @State private var searchHistory: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 固定在顶部的搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("输入搜索关键词", text: $searchText, onCommit: {
                    performSearch()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // 历史搜索记录（仅在无搜索结果且无输入时显示）
            if !searchHistory.isEmpty && searchText.isEmpty && searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("历史搜索")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    List {
                        ForEach(searchHistory, id: \.self) { history in
                            Button(action: {
                                searchText = history
                                performSearch()
                            }) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.gray)
                                    Text(history)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                        .onDelete(perform: deleteHistory)
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: CGFloat(min(searchHistory.count, 5)) * 44) // 限制高度显示最多5条
                }
                .padding(.top, 0)
            }
            
            // 搜索结果或空白状态
            if isSearching {
                ProgressView()
                    .padding()
                Spacer()
            } else if !searchResults.isEmpty {
                List {
                    ForEach(searchResults, id: \.id) { video in
                        NavigationLink(destination: VideoDetailView(video: video)) {
                            HStack {
                                Image(systemName: video.coverImage)
                                    .resizable()
                                    .frame(width: 60, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(4)
                                
                                VStack(alignment: .leading) {
                                    Text(video.name)
                                        .font(.subheadline)
                                    Text("UP主 \(video.id)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else if !searchText.isEmpty {
                Text("没有找到相关视频")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else if searchHistory.isEmpty {
                Spacer()
                Text("输入关键词搜索视频")
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("搜索")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSearchHistory()
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        addToSearchHistory(searchText)
        isSearching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allVideos = dbManager.getAllVideos()
            searchResults = allVideos.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                String($0.id).contains(searchText)
            }
            isSearching = false
        }
    }
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    
    private func addToSearchHistory(_ term: String) {
        searchHistory.removeAll { $0 == term }
        searchHistory.insert(term, at: 0)
        if searchHistory.count > 5 {
            searchHistory = Array(searchHistory.prefix(5))
        }
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    private func deleteHistory(at offsets: IndexSet) {
        searchHistory.remove(atOffsets: offsets)
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
}

#Preview {
    HomeView()
}
