//
//  BanubaConstants.swift
//
//  Created by Güney Köse on 5.10.2022.
//

import Foundation
import UIKit

enum BanubaEffectsKeys {
    case makeup, clearBrows, clearLips, clearFaceMorph, clearMakeUp, clearHair, clearEyes, clearSkin
    
    var key: String {
        switch self {
        case .makeup:
            return "Makeup"
        case .clearBrows:
            return "Brows.clear()"
        case .clearLips:
            return "Lips.clear()"
        case .clearFaceMorph:
            return "FaceMorph.clear()"
        case .clearMakeUp:
            return "Makeup.clear()"
        case .clearHair:
            return "Hair.clear()"
        case .clearEyes:
            return "Eyes.clear()"
        case .clearSkin:
            return "Skin.clear()"
        }
    }
}

enum BanubaEffectTypes {
    case face, eyes, lips, beauty, mask
    
    var effects: [[String]] {
        switch self {
        case .face:
            return [["Highlighting", "Makeup.highlighter", "Makeup.clear"],
                    ["Contouring", "Makeup.contour", "Makeup.clear"],
                    ["Foundation", "Skin.color", "Makeup.clear"],
                    ["Blush", "Makeup.blushes", "Makeup.clear"],
                    ["Softlight", "Softlight.strength", "Makeup.clear"]]
        case .eyes:
            return [["EyeLiner", "Makeup.eyeliner", "Makeup.clear"],
                    ["Eyeshadow", "Makeup.eyeshadow", "Makeup.clear"],
                    ["Eyelashes", "Makeup.lashes", "Makeup.clear"]]
        case .lips:
            return [["Matt lipstick", "Lips.matt", "Lips.clear"],
                    ["Shiny lipstick", "Lips.shiny", "Lips.clear"],
                    ["Glitter lipstick", "Lips.glitter", "Lips.clear"]]
        case .beauty:
            return [["Teeth whitening", "Teeth.whitening", "TeethWhitening.strength"],
                    ["Eyes morphing", "FaceMorph.eyes", "FaceMorph.clear"],
                    ["Face morphing", "FaceMorph.face", "FaceMorph.clear"],
                    ["Nose morphing", "FaceMorph.nose", "FaceMorph.clear"],
                    ["Skin softening", "Skin.softening", "Skin.softening"],
                    ["Skin coloring", "Skin.color", "Skin.clear"],
                    ["Hair coloring", "Hair.color", "Hair.clear"],
                    ["Eyes coloring", "Eyes.color", "Eyes.clear"],
                    ["Eye flare", "Eyes.flare", "Eyes.flare"],
                    ["Eyes whitening", "Eyes.whitening", "Eyes.whitening"]]
        case .mask:
            return [[""]] //Edit later
        }
    }
    
    var imageNames: [String] {
        switch self {
        case .face:
            return [
                "iconlyBoldHighlighting", "iconlyBoldContouring", "iconlyBoldFondation",
                "iconlyBoldAddBlush", "iconlyBoldSoftlight"
            ]
        case .eyes:
            return [
                "iconlyBoldEyeMackups", "iconlyBoldEyeshadow", "iconlyBoldEyelashes"
            ]
        case .lips:
            return [
                "iconlyBoldMat", "iconlyBoldGlitter", "iconlyBoldShiny"
            ]
        case .beauty:
            return [
                "teeth", "eyeMorphing", "faceRecognition", "nose", "faceMask" ,"skinColor", "femaleHairstyle",
                "eyeRecognize", "eyeMorphing", "businessEye"
            ]
        case .mask:
            return [
                "Beauty_4", "Beauty_5", "BeautyFaceMask", "BulldogHarlamov", "Catwoman", "Chroma", "DarkQueen_Low",
                "FashionDemon", "FemaleNightMask", "Lut_Japan", "Lut_lilac", "Lut_milano", "Lut_PurpleDreams", "Makeup_Bridal",
                "Makeup_Smokey", "MinniMouseAdult", "MorphingBow_2", "Nun", "NY19ChristmasWhiteRabbitLow", "Santa80s", "TrollGrandma"
            ]
        }
    }
    
    var colorArray: [String] {
        return [
            "#FF6633", "#FFB399", "#FF33FF", "#FFFF99", "#00B3E6",
            "#E6B333", "#3366E6", "#999966", "#99FF99", "#B34D4D",
            "#80B300", "#809900", "#E6B3B3", "#6680B3", "#66991A",
            "#FF99E6", "#CCFF1A", "#FF1A66", "#E6331A", "#33FFCC",
            "#66994D", "#B366CC", "#4D8000", "#B33300", "#CC80CC",
            "#66664D", "#991AFF", "#E666FF", "#4DB3FF", "#1AB399",
            "#E666B3", "#33991A", "#CC9999", "#B3B31A", "#00E680",
            "#4D8066", "#809980", "#E6FF80", "#1AFF33", "#999933",
            "#FF3380", "#CCCC00", "#66E64D", "#4D80CC", "#9900B3",
            "#E64D66", "#4DB380", "#FF4D4D", "#99E6E6", "#FFFFFF"
        ]
    }
    
    var userDefaultsKeys: String {
        switch self {
        case .face, .eyes, .lips:
            return "BanubaSettingsMakeup"
        case .beauty:
            return "BanubaSettingsBeauty"
        case .mask:
            return "BanubaSettingsMask"
        }
    }
    
    var userDefaultsKeyColor: String {
        switch self {
        case .face, .eyes, .lips:
            return "BanubaSettingsMakeupColor"
        case .beauty:
            return "BanubaSettingsBeautyColor"
        case .mask:
            return ""
        }
    }
    
    var isColorSliderHidden: [Bool] {
        switch self {
        case .face, .eyes, .lips:
            return [false]
        case .beauty:
            return [true, true, true, true, true, false, false, false, true, true]
        case .mask:
            return [true]
        }
    }
}

var makeupIntensityDictionary: [String : Float] = [:]
var beautyIntensityDictionary: [String : Float] = [:]

var makeupColorDictionary: [String : String] = [:]
var beautyColorDictionary: [String : String] = [:]


internal let banubaClientToken = "YOUR CLIENT TOKEN"
