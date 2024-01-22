//
//  function.swift
//  HasWarning
//
//  Copyright (c) 2024 BB9z, MIT License
//

import Foundation

func foo() {
    var array = [1, 2, 3]
    let outOfBounds = array[5]
    var optionalVariable: Int!
    optionalVariable = outOfBounds

    print(optionalVariable + 1)
}
