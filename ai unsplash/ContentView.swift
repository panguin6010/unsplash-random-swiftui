//
//  ContentView.swift
//  ai unsplash
//
//  Created by Shlomo Isaacs on 12/29/22.
//

import SwiftUI
import Alamofire
import UIKit

struct ContentView: View {
  @State private var image: UIImage?
  @State private var loading = false
  @State private var errorMessage: String?
  @State private var imageHistory: [UIImage] = []

  var body: some View {
    NavigationView {
      VStack {
        if image != nil {
          Image(uiImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
          HStack {
            Button(action: shareImage) {
              Image(systemName: "square.and.arrow.up")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button(action: saveImage) {
              Image(systemName: "tray.and.arrow.down")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
        } else if errorMessage != nil {
          Text(errorMessage!)
            .font(.title)
            .foregroundColor(.red)
        } else {
          Text("Tap the button to fetch an image")
            .font(.title)
        }

        Spacer()

        Button(action: fetchRandomImage) {
          Text("Fetch Image")
        }
        .disabled(loading)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
      }
      .padding()
      .navigationBarTitle("Image Viewer")
      .navigationBarItems(trailing:
        NavigationLink(destination: ImageHistoryView(imageHistory: $imageHistory)) {
          Image(systemName: "book.fill")
        }
      )
    }
  }

  func fetchRandomImage() {
    self.loading = true
    AF.request("https://source.unsplash.com/random").response { response in
      self.loading = false
      if let data = response.data, let newImage = UIImage(data: data) {
        self.image = newImage
        self.imageHistory.append(newImage)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
      } else {
        self.errorMessage = "Failed to load image"
      }
    }
  }

    func shareImage() {
      if let image = image {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
      }
    }

    func saveImage() {
      if let image = image {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
      }
    }
  }

struct ImageHistoryView: View {
  @Binding var imageHistory: [UIImage]

  var body: some View {
    List(imageHistory, id: \.self) { image in
      VStack {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
        HStack {
          Button(action: {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
          }) {
            Image(systemName: "square.and.arrow.up")
          }
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)

          Button(action: {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
          }) {
            Image(systemName: "tray.and.arrow.down")
          }
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
      }
    }
    .navigationBarTitle("Image History")
  }
}
