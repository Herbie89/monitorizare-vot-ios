//
//  QuestionListViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 26/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class QuestionListViewController: MVViewController {
    
    var model: QuestionListViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Object
    
    init(withModel model: QuestionListViewModel) {
        self.model = model
        super.init(nibName: "QuestionListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = model.title
        configureTableView()
        addContactDetailsToNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInterface()
    }
    
    // MARK: - Config
    
    fileprivate func configureTableView() {
        tableView.register(UINib(nibName: "QuestionTableCell", bundle: nil), forCellReuseIdentifier: QuestionTableCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    // MARK: - UI
    
    fileprivate func updateInterface() {
        tableView.reloadData()
    }
    
    // MARK: - Actions

    fileprivate func openQuestion(_ question: QuestionCellModel) {
        guard let questionAnswer = QuestionAnswerViewModel(withFormUsingCode: model.formCode,
                                                           currentQuestionId: question.questionId) else { return }
        let controller = QuestionAnswerViewController(withModel: questionAnswer)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension QuestionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionTableCell.identifier, for: indexPath) as! QuestionTableCell
        let questionsInSection = model.questions(inSection: indexPath.section)
        let question = questionsInSection[indexPath.row]
        cell.update(withModel: question)
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let questionsInSection = model.questions(inSection: section)
        return questionsInSection.count
    }
}


extension QuestionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = tableView.bounds.width
        let header = DefaultTableHeader(frame: CGRect(x: 0, y: 0, width: width, height: TableSectionHeaderHeight))
        let title = model.sectionTitles[section]
        header.titleLabel.text = title
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableSectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TableSectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let questionsInSection = model.questions(inSection: indexPath.section)
        let question = questionsInSection[indexPath.row]
        openQuestion(question)
    }
}
