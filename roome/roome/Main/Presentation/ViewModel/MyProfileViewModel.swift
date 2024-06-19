//
//  MyProfileViewModel.swift
//  roome
//
//  Created by minsong kim on 6/19/24.
//

import Combine
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import UIKit

class MyProfileViewModel {
    struct Input {
        let tappedShareButton: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let handleShareButton: AnyPublisher<Void, Never>
    }
    
//    func transform(_ input: Input) -> Output {
//        let share = input.tappedShareButton
//            .compactMap { [weak self] _ in
//                self?.updateImageToKakaoServer()
//            }
//            .eraseToAnyPublisher()
//        
//        return Output(handleShareButton: share)
//    }
    
    func updateImageToKakaoServer() {
        let image = ImageManager.loadImageFromDirectory(identifier: .profile)
        
        if let profileImage = image {
            ShareApi.shared.imageUpload(image: profileImage) { (imageUploadResult, error ) in
                if let error = error {
                    print(error)
                }
                else {
                    print("🔥🔥🔥🔥🔥")
                    print("imageUpload() success.")
                    let url = imageUploadResult?.infos.original.url
                    self.configureShare(imageURL: url)
                }
            }
        }
    }
    
    private func configureShare(imageURL: URL?) {
        if ShareApi.isKakaoTalkSharingAvailable() {
            let appLink = Link(iosExecutionParams: ["key1":"value1"])
            let button = Button(title: "나도 하러 가기", link: appLink)
            
            let content = Content(title: "나만의 방탈출 프로필", imageUrl: imageURL, link: appLink)
            
            let template = FeedTemplate(content: content, buttons: [button])
            
            if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
                
                //생성한 메시지 템플릿 객체를 jsonObject로 변환
                if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                    ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(linkResult, error) in
                        if let error = error {
                            print("error : \(error)")
                        }
                        else {
                            print("defaultLink(templateObject:templateJsonObject) success.")
                            guard let linkResult = linkResult else { return }
                            UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
}
