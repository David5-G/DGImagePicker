
Pod::Spec.new do |spec|
  spec.name         = 'DGImagePicker'
  spec.version      = '0.0.1'
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.homepage     = 'https://github.com/David5-G/DGImagePicker'
  spec.authors      = { 'david' => '2632771473@qq.com' }
  spec.summary      = 'a tool for image picker'
  spec.source       = { :git => "https://github.com/David5-G/DGImagePicker.git", :tag => spec.version }
   
  spec.ios.deployment_target  = '8.0'
  spec.requires_arc = true
  spec.frameworks   = 'UIKit' 

  spec.source_files  = 'DGImagePicker/DGImagePicker/*.{h,m}'

  spec.subspec '裁剪' do |clip|
  clip.source_files = 'DGImagePicker/DGImagePicker/裁剪/*.{h,m}'
  end

  spec.subspec '预览' do |preView|
  preView.source_files = 'DGImagePicker/DGImagePicker/预览/*.{h,m}'
  end


  spec.subspec '选图' do |imgSelect|
  imgSelect.source_files = 'DGImagePicker/DGImagePicker/选图/*.{h,m}'
  imgSelect.subspec 'View' do |view|
  view.source_files = 'DGImagePicker/DGImagePicker/选图/View/*.{h,m}'
  end
  end

  spec.subspec 'icons' do |icons|
  icons.source_files = 'DGImagePicker/DGImagePicker/icons/*'
  end

  spec.subspec 'Tool' do |tool|
  tool.source_files = 'DGImagePicker/DGImagePicker/Tool/*.{h,m}'
  end

end
