//
//  ViewController.swift
//  test25090702
//
//  Created by 黃庭璋 on 2025/9/7.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController {
    
    // UI 元件
    private let takePhotoButton = UIButton(type: .system)
    private let selectPhotoButton = UIButton(type: .system)
    private let imageView = UIImageView()
    private let pathLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI 設定
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 設定拍照按鈕
        takePhotoButton.setTitle("拍照", for: .normal)
        takePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        takePhotoButton.backgroundColor = .systemBlue
        takePhotoButton.setTitleColor(.white, for: .normal)
        takePhotoButton.layer.cornerRadius = 8
        takePhotoButton.addTarget(self, action: #selector(takePhotoTapped), for: .touchUpInside)
        
        // 設定選取圖片按鈕
        selectPhotoButton.setTitle("選擇圖片", for: .normal)
        selectPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        selectPhotoButton.backgroundColor = .systemGreen
        selectPhotoButton.setTitleColor(.white, for: .normal)
        selectPhotoButton.layer.cornerRadius = 8
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
        
        // 設定圖片顯示區域
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        // 設定路徑標籤
        pathLabel.text = "圖片路徑：尚未選擇圖片"
        pathLabel.font = UIFont.systemFont(ofSize: 14)
        pathLabel.textColor = .systemGray
        pathLabel.numberOfLines = 0
        pathLabel.lineBreakMode = .byWordWrapping
        
        // 設定滾動視圖
        scrollView.showsVerticalScrollIndicator = true
        
        // 添加所有視圖
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(takePhotoButton)
        contentView.addSubview(selectPhotoButton)
        contentView.addSubview(imageView)
        contentView.addSubview(pathLabel)
        
        // 設定自動布局
        [scrollView, contentView, takePhotoButton, selectPhotoButton, imageView, pathLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - 約束設定
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 滾動視圖約束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 內容視圖約束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 拍照按鈕約束
            takePhotoButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            takePhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            takePhotoButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 選擇圖片按鈕約束
            selectPhotoButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            selectPhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectPhotoButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 圖片視圖約束
            imageView.topAnchor.constraint(equalTo: takePhotoButton.bottomAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            // 路徑標籤約束
            pathLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            pathLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            pathLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            pathLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 按鈕事件
    @objc private func takePhotoTapped() {
        checkCameraPermission { [weak self] granted in
            if granted {
                self?.openCamera()
            } else {
                self?.showPermissionAlert(for: "相機")
            }
        }
    }
    
    @objc private func selectPhotoTapped() {
        checkPhotoLibraryPermission { [weak self] granted in
            if granted {
                self?.openPhotoLibrary()
            } else {
                self?.showPermissionAlert(for: "相簿")
            }
        }
    }
    
    // MARK: - 權限檢查
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
    
    // MARK: - 開啟相機和相簿
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "錯誤", message: "此裝置不支援相機功能")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    // MARK: - 顯示圖片資訊
    private func displayImageInfo(image: UIImage, path: String, source: String) {
        imageView.image = image
        pathLabel.text = "來源：\(source)\n路徑：\(path)\n圖片尺寸：\(Int(image.size.width)) x \(Int(image.size.height))"
    }
    
    // MARK: - 工具方法
    private func showPermissionAlert(for feature: String) {
        let alert = UIAlertController(
            title: "權限需求",
            message: "請在設定中允許APP存取\(feature)功能",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "前往設定", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        let source = picker.sourceType == .camera ? "相機拍攝" : "相簿選取"
        var imagePath = "記憶體中的圖片物件"
        
        // 如果是從相簿選取，嘗試取得檔案路徑
        if picker.sourceType == .photoLibrary {
            if let imageURL = info[.imageURL] as? URL {
                imagePath = imageURL.path
            } else if let asset = info[.phAsset] as? PHAsset {
                imagePath = "相簿資產 ID: \(asset.localIdentifier)"
            }
        }
        
        // 如果是相機拍攝，儲存到相簿
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            imagePath = "已儲存至相簿"
        }
        
        displayImageInfo(image: selectedImage, path: imagePath, source: source)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "儲存失敗", message: error.localizedDescription)
        }
    }
}

