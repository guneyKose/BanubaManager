//
//  BanubaManager.swift
//
//  Created by Güney Köse on 5.10.2022.
//

import Foundation
import BNBSdkApi
import BNBSdkCore
import AgoraRtcKit

final class BanubaManager {
    
    static let shared: BanubaManager = {
        return BanubaManager()
    }()
        
    let sdkManager = BanubaSdkManager()
    
    typealias banubaHandler = ((_ openBanuba: Bool) -> Void)
    
    public var currentEffect: BNBEffect? = nil
    
    public var isBNBActive = true
    
    public var currentEffectKey: String = BanubaEffectsKeys.makeup.key
    
    fileprivate var cameraSession: CameraSessionType = .FrontCameraSession
    
    /**
     Starts Banuba without Agora.
     */
    public func startBNBWithoutAgora(localVideo: EffectPlayerView, effect: String) {
        sdkManager.setup(configuration: EffectPlayerConfiguration())
        sdkManager.setRenderTarget(view: localVideo, playerConfiguration: nil)
        sdkManager.startEffectPlayer()
        currentEffect = sdkManager.loadEffect(effect)
        sdkManager.input.startCamera()
        self.applyLastEffects()
    }
    
    /**
     Sets up Banuba and adds Banuba to local video frame.
     */
    public func initBanuba(localVideo: EffectPlayerView, completion: @escaping () -> Void) {
        sdkManager.setup(configuration: EffectPlayerConfiguration())
        sdkManager.setRenderTarget(view: localVideo, playerConfiguration: nil)
        completion()
    }
    
    /**
     Loads selected Banuba Effect and starts to display effects on screen.
     */
    public func startBNBEffects(effect: String, agoraKit: AgoraRtcEngineKit) {
        isBNBActive = true
        sdkManager.effectManager()?.setEffectVolume(0)
        sdkManager.startEffectPlayer()
        currentEffect = sdkManager.loadEffect(effect)
        sdkManager.input.startCamera() //3rd
        self.applyLastEffects()
        sdkManager.output?.startForwardingFrames(handler: { (pixelBuffer) -> Void in
            self.pushPixelBufferIntoAgoraKit(pixelBuffer: pixelBuffer, agoraKit: agoraKit)
        })
    }
    
    /**
     Pushes Banuba video to agora engine.
     */
    public func pushPixelBufferIntoAgoraKit(pixelBuffer: CVPixelBuffer, agoraKit: AgoraRtcEngineKit) {
        let videoFrame = AgoraVideoFrame()
        videoFrame.format = 12 // means iOS texture (CVPixelBufferRef)
        videoFrame.time = CMTimeMakeWithSeconds(NSDate().timeIntervalSince1970, preferredTimescale: 1000)
        videoFrame.textureBuf = pixelBuffer
        agoraKit.pushExternalVideoFrame(videoFrame)
    }
    
    /**
     Stops Banuba  Effects.
     */
    public func stopBNBEffects() {
        sdkManager.input.stopCamera()
    }
    
    /**
     Continues to Banuba  Effects.
     */
    public func continueBNBEffects() {
        sdkManager.input.startCamera()
    }
    
    /**
     Destroys Banuba Effect Player and SDK manager.
     */
    public func destroyBNBEffects() {
        isBNBActive = false
        sdkManager.destroyEffectPlayer()
        sdkManager.destroy()
    }
    
    /**
     Clears all visible effects.
     */
    public func clearBNBEffects() {
        currentEffect?.evalJs(BanubaEffectsKeys.clearMakeUp.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearBrows.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearLips.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearFaceMorph.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearHair.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearEyes.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearSkin.key, resultCallback: nil)
    }
    
    /**
     Clears makeup effects.
     */
    public func clearMakeup(onlyLips: Bool) {
        if onlyLips {
            currentEffect?.evalJs(BanubaEffectsKeys.clearLips.key, resultCallback: nil)
        } else {
            currentEffect?.evalJs(BanubaEffectsKeys.clearMakeUp.key, resultCallback: nil)
            currentEffect?.evalJs(BanubaEffectsKeys.clearLips.key, resultCallback: nil)
        }
    }
    
    /**
     Clears beauty effects.
     */
    public func clearBeauty() {
        currentEffect?.evalJs(BanubaEffectsKeys.clearHair.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearEyes.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearSkin.key, resultCallback: nil)
        currentEffect?.evalJs(BanubaEffectsKeys.clearFaceMorph.key, resultCallback: nil)
    }
    
    /**
     Clears all effects and defaults.
     */
    public func resetAllSettings() {
        clearBNBEffects()
        resetSettings(.beauty)
        resetSettings(.eyes)
        resetSettings(.face)
        resetSettings(.lips)
    }
    
    /**
     Loads effect.
     */
    public func loadEffect(effect: String) {
        clearBNBEffects()
        currentEffect = sdkManager.loadEffect(effect)
        if effect == BanubaEffectsKeys.makeup.key {
            applyLastEffects()
        }
    }
    
    /**
     Changes hair color etc.
     */
    public func changeBNBEffect(effect: String, feature: String) {
        currentEffect?.callJsMethod(effect, params: feature)
    }
    
    /**
     Switches camera.
     */
    public func switchCamera() {
        if cameraSession == .FrontCameraSession {
            sdkManager.input.switchCamera(to: .BackCameraSession) { self.cameraSession = .BackCameraSession }
        } else {
            sdkManager.input.switchCamera(to: .FrontCameraSession) { self.cameraSession = .FrontCameraSession }
        }
    }
    
    /**
     Saves latest banuba settings of the user.
     */
    public func saveSettings(_ index: Int, _ effectType: BanubaEffectTypes, _ value: Float?, _ hex: String?) {
        switch effectType {
        case .face, .eyes, .lips:
            if value != nil {
                makeupIntensityDictionary[effectType.effects[index][1]] = value
                saveDictionary(effectType, dictionary: makeupIntensityDictionary, isColorEnabled: false)
            }
            if hex != nil {
                makeupColorDictionary[effectType.effects[index][1]] = hex
                saveDictionary(effectType, dictionary: makeupColorDictionary, isColorEnabled: true)
            }
        case .beauty:
            if value != nil {
                beautyIntensityDictionary[effectType.effects[index][1]] = value
                saveDictionary(effectType, dictionary: beautyIntensityDictionary, isColorEnabled: false)
            }
            if hex != nil {
                beautyColorDictionary[effectType.effects[index][1]] = hex
                saveDictionary(effectType, dictionary: beautyColorDictionary, isColorEnabled: true)
            }
        case .mask: break
        }
    }
    
    public func saveLastLipsMakeup(effect: String) {
        UserDefaults.standard.set(effect, forKey: "LipsMakeup")
    }
    
    public func getLastLipsMakeup() -> String {
        return UserDefaults.standard.string(forKey: "LipsMakeup") ?? ""
    }
    
    /**
     Clears user defaults for Banuba.
     */
    public func resetSettings(_ effectType: BanubaEffectTypes) {
        UserDefaults.standard.removeObject(forKey: effectType.userDefaultsKeys)
        UserDefaults.standard.removeObject(forKey: effectType.userDefaultsKeyColor)
        switch effectType {
        case .face, .eyes, .lips:
            makeupIntensityDictionary = [:]
            makeupColorDictionary = [:]
        case .beauty:
            beautyColorDictionary = [:]
            beautyIntensityDictionary = [:]
        case .mask: break
        }
    }
    
    fileprivate func saveDictionary(_ effectType: BanubaEffectTypes, dictionary: [AnyHashable: Any], isColorEnabled: Bool) {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
        ), let theJSONText = String(data: theJSONData, encoding: String.Encoding.ascii) {
            let key = isColorEnabled ? effectType.userDefaultsKeyColor : effectType.userDefaultsKeys
            UserDefaults.standard.set(theJSONText, forKey: key)
        }
    }
    
    /**
     Get dictionary object from User Defaults.
     */
    public func getBNBSettings(effectType: BanubaEffectTypes, isColorEnabled: Bool) -> Dictionary<AnyHashable, Any> {
        let key = isColorEnabled ? effectType.userDefaultsKeyColor : effectType.userDefaultsKeys
        return getBNBDefaults(key: key)
    }
    
    /**
     Get latest effects.
     */
    public func getBNBDefaults(key: String) -> Dictionary<AnyHashable, Any> {
        if let gatheredData: String = UserDefaults.standard.string(forKey: key), let data = gatheredData.data(using: .utf8) {
            do {
                if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                    return jsonData
                } else {
                #if DEBUG
                    debugPrint("error on userdefaults++ getConversionDatas on jsonSerialization")
                    return [:]
                #endif
                }
            } catch {
            #if DEBUG
                debugPrint(error.localizedDescription)
            #endif
                return [:]
            }
        } else {
            return [:]
        }
    }
    
    /**
     Apply latest makeup or beauty to user.
     */
    public func applyLastEffects() {
        self.clearBNBEffects()
        self.applyLatestEffects(type: .face)
        self.applyLatestEffects(type: .lips)
        self.applyLatestEffects(type: .eyes)
        self.applyLatestEffects(type: .beauty)
    }
    
    /**
     Apply latest makeup or beauty to user.
     */
    fileprivate func applyLatestEffects(type: BanubaEffectTypes) {
        if let colorDictionary = self.getBNBDefaults(key: type.userDefaultsKeyColor) as? [String : String],
           let alphaDictionary = self.getBNBDefaults(key: type.userDefaultsKeys) as? [String : Float] {
            
            type.effects.forEach { effect in
                let colorHex = colorDictionary[effect[1]] ?? ""
                let banubaAlpha = (alphaDictionary[effect[1]] ?? 0) / 100
                let currentColor = UIColor.colorConverter(colorHex)
                let colorString = currentColor.getColorStringRepresentation(withAlpha: banubaAlpha)
                if effect[0] == "Skin coloring" || effect[0] == "Hair coloring" || effect[0] == "Eyes coloring" || type != .beauty {
                    if type == .lips {
                        let lipEffect = self.getLastLipsMakeup()
                        let colorHexLips = colorDictionary[lipEffect] ?? ""
                        let lipAlpha = (alphaDictionary[lipEffect] ?? 0) / 100
                        let lipColor = UIColor.colorConverter(colorHexLips)
                        let lipColorStr = lipColor.getColorStringRepresentation(withAlpha: lipAlpha)
                        self.changeBNBEffect(effect: lipEffect , feature: lipColorStr)
                    } else {
                        self.changeBNBEffect(effect: effect[1], feature: colorString)
                    }
                } else {
                    self.changeBNBEffect(effect: effect[1], feature: "\(banubaAlpha)")
                }
            }
        }
    }
}
