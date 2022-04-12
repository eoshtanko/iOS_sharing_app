//
//  SearchController.swift
//  HSE Sharing
//
//  Created by Екатерина on 11.03.2022.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var activityIndicator: UIActivityIndicatorView!
    static let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    private let refreshControl = UIRefreshControl()
    
    private var skills: [Skill] = []
    private var filteredSkills: [Skill] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureActivityIndicator()
        makeInitialRequest()
        configureView()
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
        configurePullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationTitle()
    }
    
    private func makeInitialRequest() {
        activityIndicator.startAnimating()
        Api.shared.getSkills { result in
            switch result {
            case .success(let skills):
                DispatchQueue.main.async {
                    self.skills = skills ?? []
                    self.filteredSkills = self.skills
                    SearchViewController.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showFailAlert()
                }
            }
        }
    }
    
    @objc private func makeRenewRequest() {
        activityIndicator.startAnimating()
        Api.shared.getSkills { result in
            switch result {
            case .success(let skills):
                DispatchQueue.main.async {
                    self.skills = skills ?? []
                    self.filteredSkills = self.skills
                    SearchViewController.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.showFailAlert()
                }
            }
        }
    }
    
    private func configurePullToRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Updating")
        refreshControl.addTarget(self, action: #selector(makeRenewRequest), for: .valueChanged)
        SearchViewController.tableView.addSubview(refreshControl)
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        view.addSubview(activityIndicator)
    }
    
    private func showFailAlert() {
        let successAlert = UIAlertController(title: "Ошибка сети", message: "Проверьте интернет.", preferredStyle: UIAlertController.Style.alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        present(successAlert, animated: true, completion: nil)
    }
    
    private func configureView() {
        view.backgroundColor = .white
    }
    
    private func configureTableView() {
        SearchViewController.tableView.register(
            UINib(nibName: String(describing: SearchSkillCell.self), bundle: nil),
            forCellReuseIdentifier: SearchSkillCell.identifier
        )
        SearchViewController.tableView.dataSource = self
        SearchViewController.tableView.delegate = self
        view.addSubview(SearchViewController.tableView)
        configureTableViewAppearance()
    }
    
    private func configureTableViewAppearance() {
        SearchViewController.tableView.backgroundColor = .white
        NSLayoutConstraint.activate([
            SearchViewController.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            SearchViewController.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            SearchViewController.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            SearchViewController.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        SearchViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        SearchViewController.tableView.rowHeight = UITableView.automaticDimension
        SearchViewController.tableView.estimatedRowHeight = 400
    }
    
    private func configureNavigationBar() {
        configureNavigationTitle()
        configureNavigationButton()
    }
    
    private func configureNavigationTitle() {
        navigationItem.title = EnterViewController.isEnglish ? "Skills search" : "Поиск навыков"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureNavigationButton() {
        let settingsButton = UIButton()
        settingsButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        settingsButton.imageView?.tintColor = .systemBlue
        settingsButton.contentHorizontalAlignment = .fill
        settingsButton.contentVerticalAlignment = .fill
        settingsButton.imageView?.contentMode = .scaleAspectFill
        settingsButton.imageView?.clipsToBounds = true
//        settingsButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSkills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchSkillCell.identifier,
            for: indexPath)
        guard let searchCell = cell as? SearchSkillCell else {
            return cell
        }
        let skill = filteredSkills[indexPath.row]
        searchCell.configureCell(skill)
        return searchCell
    }
}

extension SearchViewController: UISearchBarDelegate {

    private func configureSearchBar() {
        SearchViewController.tableView.tableHeaderView = searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.enablesReturnKeyAutomatically = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredSkills = searchText.isEmpty ? skills : skills.filter {
            (item: Skill) -> Bool in
            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        SearchViewController.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

