//
//  BreedDetailVIew.swift
//  Assesment
//
//  Created by Edevane Tan on 18/12/2024.
//

import SwiftUI

struct BreedDetailView: View {

    let data: Animal
    let viewModel: CatViewModelContract?
    let dismissAction: (() -> Void)?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: UIMarginSpec.wide.rawValue) {
                    breedPhoto

                    breedName

                    VStack(alignment: .leading,
                           spacing: UIMarginSpec.standard.rawValue) {
                        breedDescription

                        breedOrigin

                        breedLifespan

                        breedTemperament
                    }
                }
            }
            .background(Color("BreedDetailBGColor"))
            .contentMargins(.top,
                            UIMarginSpec.wide.rawValue,
                            for: .scrollContent)
            .contentMargins(.horizontal,
                            UIMarginSpec.standard.rawValue,
                            for: .scrollContent)
            .navigationTitle("Breed Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    viewModel?.favouriteCatData(for: data)
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
        .onDisappear {
            guard let dismissAction else {
                return
            }
            dismissAction()
        }
    }

    @ViewBuilder var breedPhoto: some View {
        if let imageData = data.image,
           let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 250, maxHeight: 250)
                .clipShape(.rect(cornerRadius: 25))
        } else {
            self.fetchPhoto(for: data.referencePhotoID)
                .frame(maxWidth: 250, maxHeight: 250)
                .clipShape(.rect(cornerRadius: 25))
        }
    }

    @ViewBuilder var breedName: some View {
        Text(data.name)
            .font(.title)
            .bold()
    }

    @ViewBuilder var breedOrigin: some View {
        if let origin = data.origin {
            HStack(spacing: UIMarginSpec.extraNarrow.rawValue) {
                Text("Origin:")
                    .bold()
                Text(origin)
            }
        }
    }

    @ViewBuilder var breedLifespan: some View {
        if let lifespan = data.lifespan {
            HStack(spacing: UIMarginSpec.extraNarrow.rawValue) {
                Text("Lifespan:")
                    .bold()
                Text(lifespan)
            }
        }
    }

    @ViewBuilder var breedTemperament: some View {
        if let temperament = data.temperament,
           temperament.count > 0 {
            HStack(alignment: .top,
                   spacing: UIMarginSpec.extraNarrow.rawValue) {
                Text("Temperament:")
                    .bold()
                Text(temperament.joined(separator: ", "))
                    .lineSpacing(1.25)
            }
        }
    }

    @ViewBuilder var breedDescription: some View {
        if let description = data.breedDescription {
            Text(description)
                .lineSpacing(1.25)
        }
    }

    @ViewBuilder func fetchPhoto(for referenceID: String?) -> some View {
        if let referenceID {
            let baseURL = "https://cdn2.thecatapi.com/images/"
            let url = URL(string: baseURL + referenceID + ".jpg")
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
        }
    }
}

#Preview {
    let sampleData = Cat(id: "munc",
                         name: "Munchkin",
                         origin: "United States",
                         breedDescription: "The Munchkin is an outgoing cat who enjoys being handled. She has lots of energy and is faster and more agile than she looks. The shortness of their legs does not seem to interfere with their running and leaping abilities.", // swiftlint:disable:this line_length
                         temperament: ["Agile", "Easy Going", "Intelligent", "Playful"],
                         lifespan: "10 - 15",
                         wikipediaURL: "https://en.wikipedia.org/wiki/Munchkin_(cat)",
                         referencePhotoID: "j5cVSqLer")
    BreedDetailView(data: sampleData, viewModel: nil, dismissAction: nil)
}
