//
//  ContentView.swift
//  TryStuff
//
//  Created by Kilo Loco on 4/11/24.
//

import SwiftUI

func useClosure(completion: @escaping (Int) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 2)  {
        print(Thread.isMainThread)
        completion(1)
    }
}

func useAsync() async -> Int {
    let task = Task { () -> Int in
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return 2
    }
    let result = await task.result
    return try! result.get()
}

struct ContentView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        VStack {
            Text(String(vm.state))
                .font(.largeTitle)
            Button("Do something closure") {
                vm.doSomethingClosure()
            }
            Button("Do something Async") {
                vm.doSomethingAsync()
            }
        }
        .padding()
    }
    
    // Main actor works as expected when within a View/Struct
//    @MainActor
//    func doSomethingClosure() {
//        useClosure { result in
//            self.state = result
//        }
//    }
//    
//    @MainActor
//    func doSomethingAsync() {
//        Task {
//            let result = await useAsync()
//            self.state = result
//        }
//    }
}

class ViewModel: ObservableObject {
    @Published var state = 0
    
    @MainActor
    func doSomethingClosure() {
        useClosure { [weak self] result in
            guard let self =  self else { return }
            Task { @MainActor [weak self] in
                self?.state = result
            }
        }
    }
    
    @MainActor
    func doSomethingAsync() {
        Task {
            let result = await useAsync()
            self.state = result
        }
    }
}
