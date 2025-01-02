//
//  ListView.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 11/09/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCListViewDelegate: AnyObject {
    func didSelect(item: String, component: SCListView)
    func didScroll(component: SCListView)
}

class SCListView: UIView, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    private let tableView: UITableView
    private var items: [String]

    private weak var delegate: SCListViewDelegate?

    init(items: [String], frame: CGRect, delegate: SCListViewDelegate?) {
        self.items = items
        self.delegate = delegate
        tableView = UITableView()
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SCListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SCListTableViewCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }

    func update(items: [String]) {
        self.items = items
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SCListTableViewCell.self), for: indexPath) as? SCListTableViewCell else {
            return UITableViewCell()
        }
        cell.itemNameLabel.text = items[indexPath.row]
        cell.itemNameLabel.adjustsFontForContentSizeCategory = true
        cell.itemNameLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(item: items[indexPath.row], component: self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(component: self)
    }
}
