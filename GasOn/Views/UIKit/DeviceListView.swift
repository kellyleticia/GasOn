//
//  DeviceListView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 30/09/24.
//

import UIKit

class DeviceListViewController: UIViewController {
    var viewModel: DeviceListViewModel!
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    static func create(with viewModel: DeviceListViewModel) -> DeviceListViewController {
        let vc = DeviceListViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        observeBluetoothUpdates()
    }
    
    private func observeBluetoothUpdates() {
        viewModel.bluetoothService.onPeripheralsUpdated = { [weak self] in
            self?.viewModel.updateFilteredPeripherals()
            self?.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(DeviceRowCell.self, forCellReuseIdentifier: "DeviceRowCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension DeviceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceRowCell", for: indexPath) as? DeviceRowCell else {
            return UITableViewCell()
        }
        
        let peripheral = viewModel.filteredPeripherals[indexPath.row]
        cell.nameLabel.text = peripheral.peripheral.name ?? "Desconhecido"
        cell.statusLabel.text = peripheral.isConnected ? "Conectado" : "Não Conectado"
        return cell
    }
}

extension DeviceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = viewModel.filteredPeripherals[indexPath.row]
        viewModel.connectOrDisconnect(peripheral)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
