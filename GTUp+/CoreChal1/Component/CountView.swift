//
//  CounteView.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 05/04/25.
//

import SwiftUI

struct CountView: View {
    let type: String
    let count: Int
    
    var unit: [String] {
        switch type {
        case "Work":
            return ["workspace", "hours", "You've worked for"]
        case "Break":
            return ["walking", "minutes", "You've taken a break for"]
        default:
            return ["defaultImage", "", ""]
        }
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondaryApp)
            VStack(alignment: .leading){
                Text(type)
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.fontApp)
                HStack{
                    Image(unit[0])
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding(.leading, 13)
                    Spacer()
                    VStack(alignment: .trailing){
                        Text(unit[2])
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.fontApp)
                        Text("\(count) \(unit[1])")
                            .font(.system(size: 32, weight: .medium, design: .default))
                            .foregroundColor(.fontApp)
                    }
                }
            }
            .padding(20)
        }
        .frame(width: 350, height: 140)
        .cornerRadius(20)
    }
}

#Preview {
    CountView(type: "Work", count:1)
}
