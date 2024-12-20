//
//  CatAssembler.swift
//  Assesment
//
//  Created by Edevane Tan on 20/12/2024.
//

import Swinject
import SwinjectAutoregistration

struct CatAssembler: Assembly {
    func assemble(container: Swinject.Container) {
        container.autoregister(NetworkManager.self, initializer: NetworkManager.init)
        container.autoregister(CatApiServiceContract.self, initializer: CatApiService.init)
        container.autoregister(CatViewModelContract.self, initializer: CatViewModel.init)
    }
}
