//
//  GoogleFontViewController.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import UIKit
import Session
import Combine

class GoogleFontViewController: UIViewController {
    let viewModel: GoogleFontViewModel
    let interactor: GoogleFontInteractor
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        viewModel = GoogleFontViewModel()
        interactor = GoogleFontInteractor()
        super.init(nibName: nil, bundle: nil)
        setup()
        layoutViews()
        bindData()
    }
    
    func setup() {
        interactor.presenter = viewModel
        viewModel.viewController = self
    }
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        t.register(GoogleFontTableViewCell.self, forCellReuseIdentifier: "GoogleFontTableViewCell")
        t.refreshControl = refreshControl
        return t
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView(style: .large)
        i.translatesAutoresizingMaskIntoConstraints = false
        i.startAnimating()
        return i
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(needRefresh), for: .valueChanged)
        return r
    }()
    
    private lazy var errorLable: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Error\nPlease drop down to reload data"
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    private lazy var sampleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "This is Sample Text!"
        l.textAlignment = .center
        return l
    }()
    
    private lazy var stackScroll: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        
        return s
    }()
    
    private lazy var buttonStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 8.0
        
        return s
    }()
    
    func layoutViews() {
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorLable)
        view.addSubview(stackScroll)
        stackScroll.addSubview(buttonStack)
        view.addSubview(sampleLabel)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            
            loadingView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            errorLable.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            errorLable.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            stackScroll.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            stackScroll.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            stackScroll.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            stackScroll.heightAnchor.constraint(equalToConstant: 48),
            
            buttonStack.heightAnchor.constraint(equalTo: stackScroll.heightAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: stackScroll.leadingAnchor, constant: 8),
            buttonStack.trailingAnchor.constraint(equalTo: stackScroll.trailingAnchor, constant: -8),
            buttonStack.topAnchor.constraint(equalTo: stackScroll.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: stackScroll.bottomAnchor),
            
            sampleLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            sampleLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            sampleLabel.topAnchor.constraint(equalTo: stackScroll.bottomAnchor),
            sampleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func needRefresh() {
        interactor.loadFonts()
    }
    
    @objc func buttonDidTap(_ button: UIButton) {
        interactor.active(fontName: button.title(for: .normal))
    }
    
    private func resetButtonStack() {
        buttonStack.arrangedSubviews.forEach {
            self.buttonStack.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
        
        func generateButton(_ text: String) -> UIButton {
            let b = UIButton(type: .system)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.layer.cornerRadius = 4.0
            b.setTitle(text, for: .normal)
            b.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
            
            return b
        }
        
        viewModel
            .supportedTypes
            .forEach {
                buttonStack.addArrangedSubview(generateButton($0))
            }
        
        if let firstButton = buttonStack.arrangedSubviews.first as? UIButton {
            buttonDidTap(firstButton)
        }
        
        stackScroll.setContentOffset(.zero, animated: true)
    }
    
    private func updateButtonSelect() {
        buttonStack
            .arrangedSubviews
            .forEach {
                guard let button = $0 as? UIButton else {
                    return
                }
                
                let select = button.title(for: .normal) == viewModel.currentFont.fontName
                button.isSelected = select
            }
    }
    
    private func bindData() {
        viewModel
            .$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadingView.isHidden = !$0
                if !$0 {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .$loadingError
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.errorLable.isHidden = $0 == nil
            }
            .store(in: &cancellables)
        
        viewModel
            .$contentViewModel
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel
            .$currentFont
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.sampleLabel.font = $0
                self?.updateButtonSelect()
            }
            .store(in: &cancellables)
        
        viewModel
            .$supportedTypes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resetButtonStack()
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFonts()
    }
}

extension GoogleFontViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contentViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleFontTableViewCell") as? GoogleFontTableViewCell else {
            return UITableViewCell()
        }
        
        let model = viewModel.contentViewModel[indexPath.item]
        cell.configure(with: model)
        return cell
    }
}

extension GoogleFontViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.contentViewModel[indexPath.item]
        interactor.tap(at: model.fontModel)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// Actions
extension GoogleFontViewController {
    func loadFonts() {
        interactor.loadFonts()
    }
}
