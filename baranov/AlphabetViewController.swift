//
//  AlphabetViewController.swift
//  baranov
//
//  Created by Ivan on 12/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class AlphabetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var alphabet: [Letter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("alphabet", comment: "")
        
        // alphabet fill in
        alphabet.append(Letter(nr: 1, nv: 1, letter: "ا", notes: "Алиф\nслужит знаком долготы для фатхи\nявляется носителем хамзы", has_all_writings: false))
        alphabet.append(Letter(nr: 0, nv: 0, letter: "ى", notes: "Алиф максура", has_all_writings: false, has_nr: false))
        alphabet.append(Letter(nr: 2, nv: 2, letter: "ب", notes: "Ба"))
        alphabet.append(Letter(nr: 3, nv: 400, letter: "ت", notes: "Та"))
        alphabet.append(Letter(nr: 4, nv: 500, letter: "ث", notes: "Са"))
        alphabet.append(Letter(nr: 5, nv: 3, letter: "ج", notes: "Джим"))
        alphabet.append(Letter(nr: 6, nv: 8, letter: "ح", notes: "Ха"))
        alphabet.append(Letter(nr: 7, nv: 600, letter: "خ", notes: "Ха"))
        alphabet.append(Letter(nr: 8, nv: 4, letter: "د", notes: "Даль", has_all_writings: false))
        alphabet.append(Letter(nr: 9, nv: 700, letter: "ذ", notes: "Заль", has_all_writings: false))
        alphabet.append(Letter(nr: 10, nv: 200, letter: "ر", notes: "Ра", has_all_writings: false))
        alphabet.append(Letter(nr: 11, nv: 7, letter: "ز", notes: "Зайн", has_all_writings: false))
        alphabet.append(Letter(nr: 12, nv: 60, letter: "س", notes: "Син"))
        alphabet.append(Letter(nr: 13, nv: 300, letter: "ش", notes: "Шин"))
        alphabet.append(Letter(nr: 14, nv: 90, letter: "ص", notes: "Сад"))
        alphabet.append(Letter(nr: 15, nv: 800, letter: "ض", notes: "Дад"))
        alphabet.append(Letter(nr: 16, nv: 9, letter: "ط", notes: "Та"))
        alphabet.append(Letter(nr: 17, nv: 900, letter: "ظ", notes: "За"))
        alphabet.append(Letter(nr: 18, nv: 70, letter: "ع", notes: "Ъайн"))
        alphabet.append(Letter(nr: 19, nv: 1000, letter: "غ", notes: "Гайн"))
        alphabet.append(Letter(nr: 20, nv: 80, letter: "ف", notes: "Фа"))
        alphabet.append(Letter(nr: 21, nv: 100, letter: "ق", notes: "Каф"))
        alphabet.append(Letter(nr: 22, nv: 20, letter: "ك", notes: "Кяф"))
        alphabet.append(Letter(nr: 23, nv: 30, letter: "ل", notes: "Лям"))
        alphabet.append(Letter(nr: 24, nv: 40, letter: "م", notes: "Мим"))
        alphabet.append(Letter(nr: 25, nv: 50, letter: "ن", notes: "Нун"))
        alphabet.append(Letter(nr: 26, nv: 5, letter: "ه", notes: "Ха"))
        alphabet.append(Letter(nr: 0, nv: 0, letter: "ة", notes: "Та марбута", has_all_writings: false, has_nr: false))
        alphabet.append(Letter(nr: 27, nv: 6, letter: "و", notes: "Вав\nслужит знаком долготы для даммы\nявляется носителем хамзы", has_all_writings: false))
        alphabet.append(Letter(nr: 28, nv: 10, letter: "ي", notes: "Йа\nслужит знаком долготы для кясры\nявляется носителем хамзы"))
        
        // hide navigationController's builtin toolbar
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        // main table view setup
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alphabet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlphabetCell", for: indexPath) as! AlphabetTableViewCell
        let letter = alphabet[indexPath.row]
        
        if (letter.has_nr) {
            cell.nvLabelHeight.constant = 20.0
            cell.nvLabelTopSpace.constant = 5.0
            cell.backgroundColor = UIColor.white
            cell.nrLabel.text = String(letter.nr)
            cell.nvLabel.text = NSLocalizedString("nvLabel", comment: "") + String(letter.nv)
        } else {
            cell.nvLabelHeight.constant = 0.0
            cell.nvLabelTopSpace.constant = 0.0
            cell.nrLabel.text = ""
            cell.backgroundColor = UIColor.darkBg()
        }
        
        cell.letterLabel.text = String(letter.letter)

        if (letter.has_all_writings) {
            cell.inTheBeginningLabel.text = NSLocalizedString("inTheBeginning", comment: "") + String(letter.letter) + "ـ"
            cell.inTheMiddleLabel.text = NSLocalizedString("inTheMiddle", comment: "") + "ـ" + String(letter.letter) + "ـ"
        } else {
            cell.inTheBeginningLabel.text = NSLocalizedString("inTheBeginning", comment: "") + String(letter.letter)
            cell.inTheMiddleLabel.text = NSLocalizedString("inTheMiddle", comment: "") + "ـ" + String(letter.letter)
        }
        cell.inTheEndLabel.text = NSLocalizedString("inTheEnd", comment: "") + "ـ" + String(letter.letter)
        
        cell.notesLabel.text = letter.notes
        
        cell.layoutIfNeeded()
        
        return cell
    }

}
