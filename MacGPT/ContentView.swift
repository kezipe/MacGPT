//
//  ContentView.swift
//  MacGPT
//
//  Created by Peng, Kevin [C] on 2023-03-21.
//

import ChatGPTSwift
import SwiftUI

struct ContentView<Interactor: Interactable>: View {
    @ObservedObject var interactor: Interactor
    @State private var question = ""

    var body: some View {
        VStack {
            Text("Program is " + String(describing: interactor.state))
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(interactor.transcript) { line in
                            Text(line.message)
                                .textSelection(.enabled)
                                .lineSpacing(1)
                        }
                        Text(interactor.currentResponse)
                            .lineSpacing(1)
                            .id(0)
                    }
                }
                .onChange(of: interactor.currentResponse) { newValue in
                    proxy.scrollTo(0)
                }
            }
            .frame(height: 400)

            HStack {
                Image(systemName: "text.bubble")
                    .imageScale(.large)
                    .foregroundColor(.white)
                TextField("Ask a question. ⌥ + Return for a new line. ⌘ + Return to submit.", text: $question, axis: .vertical)
                    .lineLimit(4 ... 10)
                VStack {
                    Button("Submit", action: submit)
                        .keyboardShortcut(.return)
                        .disabled(question.isEmpty || exceededLimit)
                    VStack(spacing: 1) {
                        Text("\(question.count)")
                        Divider()
                        Text("2,048")
                    }
                    .monospacedDigit()
                    .frame(width: 40)
                    .padding(2)
                    .border(exceededLimit ? Color.red : .clear)
                }
            }
        }
        .padding()
    }

    var exceededLimit: Bool {
        question.count > 2048
    }

    func submit() {
        guard !exceededLimit else { return }
        interactor.ask(question: question)
        question.removeAll()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(interactor: DesignTimeInteractor())
    }
}
