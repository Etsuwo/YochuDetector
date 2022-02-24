//
//  ViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/24.
//

import Foundation
import Combine

protocol InputObject: AnyObject {}
protocol BindingObject: ObservableObject {}
protocol OutputObject: ObservableObject {}

protocol ViewModelObject: ObservableObject {
    associatedtype Input: InputObject
    associatedtype Binding: BindingObject
    associatedtype Output: OutputObject
    
    var input: Input { get } // ユーザ入力受付
    var binding: Binding { get } // 双方向バインディング（TextFieldなど）
    var output: Output { get } // API結果やステータスの変更によるViewの更新
}
