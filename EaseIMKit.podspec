Pod::Spec.new do |s|
    s.name             = 'EaseIMKit'
    s.version          = '3.9.4'
    s.summary = 'easemob im sdk UIKit'
    s.homepage = 'http://docs-im.easemob.com/im/ios/other/easeimkit'
    s.description = <<-DESC
                    EaseIMKit Supported features:

                    1. Conversation list
                    2. Chat page (singleChat,groupChat,chatRoom)
                    3. Contact list
                  DESC
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'easemob' => 'dev@easemob.com' }
    s.source = { :git => 'https://github.com/easemob/easeui_ios.git', :tag => 'EaseIMKit_3.9.4'}
    s.frameworks = 'UIKit'
    s.libraries = 'stdc++'
    s.ios.deployment_target = '10.0'
    s.source_files = [
        'EaseIMKit/EaseIMKit/EaseIMKit.h',
        'EaseIMKit/EaseIMKit/EasePublicHeaders.h',
        'EaseIMKit/EaseIMKit/**/*.{h,m,mm}'
    ]
    s.public_header_files = [
        'EaseIMKit/EaseIMKit/EaseIMKit.h',
        'EaseIMKit/EaseIMKit/EasePublicHeaders.h',
        'EaseIMKit/EaseIMKit/Classes/EaseIMKitManager.h',
        'EaseIMKit/EaseIMKit/Classes/EaseEnums.h',
        'EaseIMKit/EaseIMKit/Classes/Common/EaseDefines.h',
        'EaseIMKit/EaseIMKit/Classes/Contacts/Models/EaseContactsViewModel.h',
        'EaseIMKit/EaseIMKit/Classes/Contacts/Models/EaseContactModel.h',
        'EaseIMKit/EaseIMKit/Classes/Contacts/Controllers/EaseContactsViewController.h',
        'EaseIMKit/EaseIMKit/Classes/BaseTableViewController/EaseBaseTableViewModel.h',
        'EaseIMKit/EaseIMKit/Classes/Conversations/Views/EaseConversationCell.h',
        'EaseIMKit/EaseIMKit/Classes/Conversations/Models/EaseConversationViewModel.h',
        'EaseIMKit/EaseIMKit/Classes/Conversations/Models/EaseConversationModel.h',
        'EaseIMKit/EaseIMKit/Classes/Conversations/Controllers/EaseConversationsViewController.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/EaseChatViewController.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/EaseChatViewControllerDelegate.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/ChatBar/MoreView/MoreFunction/EaseExtFuncModel.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/ChatModels/EaseExtMenuModel.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/ChatModels/EaseMessageModel.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/ChatModels/EaseChatViewModel.h',
        'EaseIMKit/EaseIMKit/Classes/BaseTableViewController/EaseBaseTableViewModel.h',
        'EaseIMKit/EaseIMKit/Classes/BaseTableviewController/EaseUserDelegate.h',
        'EaseIMKit/EaseIMKit/Classes/BaseTableViewController/EaseBaseTableViewController.h',
        
        
#        'EaseIMKit/EaseIMKit/Classes/Chat/BeiQi/UserInfo/UserInfoStore.h',
        #beiqi
        'EaseIMKit/EaseIMKit/Classes/Chat/BeiQi/Conversation/EMConversationsViewController.h',
        'EaseIMKit/EaseIMKit/Classes/Helper/ViewController/RefreshController/EMRefreshViewController.h',
        'EaseIMKit/EaseIMKit/Classes/Helper/EaseIMKitOptions.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/BeiQi/EaseLoginViewController.h',
        'EaseIMKit/EaseIMKit/Classes/Home/EaseHomeViewController.h',
        'EaseIMKit/EaseIMKit/Classes/Chat/BeiQi/EaseSwitchRoleViewController.h'
        
    ]
    
    s.static_framework = true
#    s.resource = 'EaseIMKit/EaseIMKit/Resources/EaseIMKit.bundle'
   s.resources  = ['EaseIMKit/EaseIMKit/Resources/EaseIMKit.bundle','EaseIMKit/EaseIMKit/EaseCall/EaseCall.bundle','EaseIMKit/EaseIMKit/Resources/*.{xib,mp3}','EaseIMKit/EaseIMKit/Classes/Common/3rdParty/MISImagePicker/MISImagePicker/Assets/MISImagePicker.bundle','EaseIMKit/EaseIMKit/Resources/EaseKitEmoji.bundle']
   
    #s.resources = ['Images/*.png', 'Sounds/*']
    
    #s.ios.resource_bundle = { 'EaseIMKit' => 'EaseIMKit/EaseIMKit/Assets/*.png' }
    #s.resource_bundles = {
     # 'EaseIMKit' => ['EaseIMKit/EaseIMKit/Assets/*.png']
    #}
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
                              'VALID_ARCHS' => 'arm64 armv7 x86_64'
                            }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.ios.vendored_frameworks = 'EaseIMKit/HyphenateChat.framework'


    # s.dependency 'HyphenateChat', '3.9.4'
    s.dependency 'EMVoiceConvert', '0.1.0'
    s.dependency 'MBProgressHUD'
    s.dependency 'Masonry'
    s.dependency 'MJRefresh'
    s.dependency 'SDWebImage'
    # s.dependency 'AgoraRtcEngine_iOS','3.6.1.2'
    s.dependency 'AgoraRtcEngine_iOS'
    s.dependency 'FMDB'
    s.dependency 'Bugly'
    s.dependency 'EMTranslate'
#    s.dependency 'EBBannerView', '1.1.2'
    s.dependency 'TZImagePickerController'
    
end
