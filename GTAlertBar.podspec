Pod::Spec.new do |s|
    s.name             = "GTAlertBar"
    s.version          = "1.0.3"
    s.summary          = "A no-nonsense manager for showing alert bars on iOS apps."
    s.homepage         = "https://github.com/ecnepsnai/GTAlertBar"

    s.license          = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author           = {
        "Ian Spence" => "ian@ecnepsnai.com"
    }
    s.social_media_url = 'https://twitter.com/ecnepsnai'
    s.source           = {
        :git => "https://github.com/ecnepsnai/GTAlertBar.git",
        :tag => s.version.to_s
    }

    s.platform         = :ios, '8.0'
    s.source_files     = 'GTAlertBar.swift'
    s.resources        = 'GTAlertBar.xcassets'
    s.requires_arc     = true
end
