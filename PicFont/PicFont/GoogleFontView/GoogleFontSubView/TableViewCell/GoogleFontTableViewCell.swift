//
//  GoogleFontTableViewCell.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import UIKit
import Combine

class GoogleFontTableViewCell: UITableViewCell {
    var cancellable: Set<AnyCancellable> = []
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLable: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var subTitleLable: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .tintColor
        return l
    }()
    
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView(style: .medium)
        i.translatesAutoresizingMaskIntoConstraints = false
        i.isHidden = true
        i.startAnimating()
        return i
    }()
    
    func layoutViews() {
        let stack = UIStackView(arrangedSubviews: [titleLable, subTitleLable])
        stack.alignment = .fill
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 4.0
        
        let hStack = UIStackView(arrangedSubviews: [stack, iconView])
        hStack.axis = .horizontal
        hStack.alignment = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hStack)
        contentView.addSubview(indicator)
        contentView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant:  -8),
            
            indicator.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconView.leadingAnchor.constraint(equalTo: hStack.trailingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            iconView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            iconView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with model: GoogleFontTableViewCellViewModel) {
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
        
        bindData(with: model)
        titleLable.text = model.title
        subTitleLable.text = model.subTitle
    }
    
    func bindData(with model: GoogleFontTableViewCellViewModel) {
        model
            .$showLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.indicator.isHidden = !$0
            })
            .store(in: &cancellable)
        
        model
            .$titleFont
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.titleLable.font = $0
            })
            .store(in: &cancellable)
        
        model
            .$subTitleFont
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.subTitleLable.font = $0
            })
            .store(in: &cancellable)
        
        model
            .$icon
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self.iconView)
            .store(in: &cancellable)
    }
}
