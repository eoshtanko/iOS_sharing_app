//
//  ProfileViewController.swift
//  HSE Sharing
//
//  Created by Екатерина on 11.03.2022.
//

import UIKit

// Убрать кнопки редактирования и изменения языка
// мои данные -> Данные
// Поменять плейсхолдеры
// Убрать нижнюю кнопку
// Может хочет
// Добавить создание переписки

class ProfileViewController: UIViewController {
    
    var isMyProfile = true
    var user: User?
    
    var isProfileInfoEditing = false
    var nameIsValid: Bool = true
    var surnameIsValid: Bool = true
    var emailIsValid: Bool = true
    var socialNetworkIsValid: Bool = true
    
    let formatter = DateFormatter()
    let eduProgramPickerView = UIPickerView()
    let dormPickerView = UIPickerView()
    let eduStagePickerView = UIPickerView()
    let campusLocationPickerView = UIPickerView()
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var canButton: UIButton!
    @IBOutlet weak var wantButton: UIButton!
    @IBOutlet weak var russianLangButton: UIButton!
    @IBOutlet weak var englishLangButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var bottomButtom: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    @IBOutlet weak var nameTextFiled: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var socialNetworkTextField: UITextField!
    @IBOutlet weak var eduProgramTextField: UITextField!
    @IBOutlet weak var dormTextField: UITextField!
    @IBOutlet weak var stageOfEduTextField: UITextField!
    @IBOutlet weak var campusLocationTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var myDataLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var socialNetworkLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var eduProgramLabel: UILabel!
    @IBOutlet weak var dormLabel: UILabel!
    @IBOutlet weak var stageOfEduLabel: UILabel!
    @IBOutlet weak var campusLocationLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!

    @IBOutlet weak var topBottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBottomButtonConstraint: NSLayoutConstraint!

    @IBAction func unwindToProfileViewController(segue:UIStoryboardSegue) { }
    
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
        pickImage()
    }
    
    @IBAction func commentsButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Comments", bundle: nil)
        let commentsListViewController = storyboard.instantiateViewController(withIdentifier: "Comments") as! CommentsViewController
        if !isMyProfile && CurrentUser.user.isModer ?? false {
            commentsListViewController.setNeedsFocusUpdate()
        }
        navigationController?.pushViewController(commentsListViewController, animated: true)
    }
    
    @IBAction func editProfileInfoButtonPressed(_ sender: Any) {
        isProfileInfoEditing = true
        changePasswordButton.isHidden = false
        editProfileButton.layer.isHidden = true
        bottomButtom.setTitle(EnterViewController.isEnglish ? "Save" : "Сохранить", for: .normal)
        topBottomButtonConstraint.constant = 80
        bottomBottomButtonConstraint.constant = 40
        activateEditing()
    }
    
    @IBAction func canButtonPressed(_ sender: Any) {
        PersonalSkillListViewController.isContainedCanSkills = true
        goToPersonalSkillList()
    }
    
    @IBAction func wantButtonPressed(_ sender: Any) {
        PersonalSkillListViewController.isContainedCanSkills = false
        goToPersonalSkillList()
    }
    
    @IBAction func maleButtonPressed(_ sender: Any) {
        if isProfileInfoEditing {
            maleButton.tintColor = UIColor(named: "BlueDarkColor")
            femaleButton.tintColor = .gray
        }
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        if isProfileInfoEditing {
            femaleButton.tintColor = UIColor(named: "BlueDarkColor")
            maleButton.tintColor = .gray
        }
    }
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        if isProfileInfoEditing {
            changePasswordButton.isHidden = true
            isProfileInfoEditing = false
            editProfileButton.layer.isHidden = false
            bottomButtom.setTitle(EnterViewController.isEnglish ? "Log out" : "Выйти из аккаунта", for: .normal)
            topBottomButtonConstraint.constant = 40
            bottomBottomButtonConstraint.constant = 40
            deactivateEditing()
        }
    }
    
    // MARK: override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        configurePickerView()
        configureDatePicker()
        deactivateEditing()
        configureNavigationButton()
        configureTapGestureRecognizer()
        configureData()
        configureTextViewHintText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubviews()
    }
    
    // MARK: Funcs
    
    private func configureData() {
        let currentUser = user ?? CurrentUser.user
        nameTextFiled.text = currentUser?.name
        surnameTextField.text = currentUser?.surname
        emailTextField.text = currentUser?.mail
        if let birthDate = currentUser?.birthDate {
            birthdayTextField.text = formatter.string(from: birthDate)
        }
        maleButton.tintColor = currentUser?.gender == 0 ? UIColor(named: "BlueDarkColor") : .gray
        femaleButton.tintColor =  currentUser?.gender == 0 ? .gray : UIColor(named: "BlueDarkColor")
        if let studyingYearId = currentUser?.studyingYearId {
            stageOfEduTextField.text = DataInEnglish.stagesOfEdu[studyingYearId]
        }
        if let majorId = currentUser?.majorId {
            eduProgramTextField.text = DataInEnglish.universityCampuses[majorId]
        }
        if let campusLocationId = currentUser?.campusLocationId {
            campusLocationTextField.text = DataInEnglish.universityCampuses[campusLocationId]
        }
        if let dormitoryId = currentUser?.dormitoryId {
            dormTextField.text = DataInEnglish.dormitories[dormitoryId]
        }
        aboutMeTextView.text = currentUser?.about
        socialNetworkTextField.text = currentUser?.contact
        // CurrentUser.user.photo
        // averageGrade
        // isModer
        // transactions: CurrentUser.user.transactions,
        // skills: CurrentUser.user.skills,
        // feedbacks: CurrentUser.user.feedbacks,
    }
    
    private func configureTextViewHintText() {
        if aboutMeTextView.text.isEmpty || aboutMeTextView.textColor == .black {
            aboutMeTextView.text = "Расскажите о себе :)"
            aboutMeTextView.textColor = .lightGray
        }
    }
    
    func configureNavigationButton() {
        let settingsButton = UIButton()
        if EnterViewController.isEnglish {
            settingsButton.setTitle("🇷🇺", for: .normal)
        } else {
            settingsButton.setTitle("🇬🇧", for: .normal)
        }
        settingsButton.titleLabel?.font = .systemFont(ofSize: 30)
        settingsButton.addTarget(self, action: #selector(changeLanguage), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    private func configureSubviews() {
        configureProfileImageView()
        configureTextFields()
        configureButtons()
        EnterViewController.isEnglish ? translateToEnglish() : translateToRussia()
    }
    
    private func configureProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
//        if(CurrentUser.user.photo != nil) {
//           // profileImageView.image = CurrentUser.user.photo
//        }
    }
    
    private func configureTextFields() {
        configureTextFieldsDelegate(textField: nameTextFiled)
        nameTextFiled.tag = 1
        configureTextFieldsDelegate(textField: surnameTextField)
        surnameTextField.tag = 2
        configureTextFieldsDelegate(textField: emailTextField)
        emailTextField.tag = 3
        configureTextFieldsDelegate(textField: socialNetworkTextField)
        socialNetworkTextField.tag = 4
        configureTextView()
    }
    
    private func configureButtons() {
        makeButtonCircle(button: editPhotoButton)
        makeButtonCircle(button: editProfileButton)
        canButton.makeButtonOval()
        wantButton.makeButtonOval()
        bottomButtom.makeButtonOval()
    }
    
    private func configureTextView() {
        aboutMeTextView.delegate = self
        aboutMeTextView.layer.borderWidth = 0.5
        aboutMeTextView.layer.borderColor = CGColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        aboutMeTextView.layer.cornerRadius = 10
    }
    
    private func configureTextFieldsDelegate(textField: UITextField) {
        textField.delegate = self
    }
    
    private func makeButtonCircle(button: UIButton) {
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true
    }
    
    private func activateEditing() {
        nameTextFiled.isUserInteractionEnabled = true
        surnameTextField.isUserInteractionEnabled = true
        emailTextField.isUserInteractionEnabled = true
        socialNetworkTextField.isUserInteractionEnabled = true
        eduProgramTextField.isUserInteractionEnabled = true
        dormTextField.isUserInteractionEnabled = true
        stageOfEduTextField.isUserInteractionEnabled = true
        campusLocationTextField.isUserInteractionEnabled = true
        birthdayTextField.isUserInteractionEnabled = true
        aboutMeTextView.isUserInteractionEnabled = true
        maleButton.isUserInteractionEnabled = true
        femaleButton.isUserInteractionEnabled = true
    }
    
    private func deactivateEditing() {
        nameTextFiled.isUserInteractionEnabled = false
        surnameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        socialNetworkTextField.isUserInteractionEnabled = false
        eduProgramTextField.isUserInteractionEnabled = false
        dormTextField.isUserInteractionEnabled = false
        stageOfEduTextField.isUserInteractionEnabled = false
        campusLocationTextField.isUserInteractionEnabled = false
        birthdayTextField.isUserInteractionEnabled = false
        aboutMeTextView.isUserInteractionEnabled = false
        maleButton.isUserInteractionEnabled = false
        femaleButton.isUserInteractionEnabled = false
    }
    
    private func goToPersonalSkillList() {
        let storyboard = UIStoryboard(name: "PersonalSkillList", bundle: nil)
        let personalSkillListViewController = storyboard.instantiateViewController(withIdentifier: "PersonalSkillList") as! PersonalSkillListViewController
        navigationController?.pushViewController(personalSkillListViewController, animated: true)
    }
    
    private func configureTapGestureRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    enum Const {
        static let buttonBorderRadius: CGFloat = 14
        static let maxNumOfCharsInName = 16
    }
}



extension ProfileViewController {
    
    @objc private func changeLanguage() {
        ExchangesViewController.tableView.reloadData()
        SearchViewController.tableView.reloadData()
        ConversationsListViewController.tableView.reloadData()
        EnterViewController.isEnglish = !EnterViewController.isEnglish
        if (EnterViewController.isEnglish) {
            translateToRussia()
        } else {
            translateToEnglish()
        }
    }
    
    private func translateToRussia() {
        configureNavigationButton()
        translateProfileView(isEnglish: false)
    }

    private func translateToEnglish() {
        configureNavigationButton()
        translateProfileView(isEnglish: true)
    }
    
    private func translateProfileView(isEnglish: Bool) {
        if (isEnglish) {
            myDataLabel.text = "My information"
            nameLabel.text = "Name"
            nameTextFiled.placeholder = "Enter a name"
            surnameLabel.text = "Surname"
            surnameTextField.placeholder = "Enter a surname"
            emailTextField.placeholder = "Enter email"
            socialNetworkLabel.text = "Social network"
            socialNetworkTextField.placeholder = "t.me/ or vk.com/"
            aboutMeLabel.text = "About me"
            canButton.setTitle("Can", for: .normal)
            wantButton.setTitle("Want", for: .normal)
            if (aboutMeTextView.text == "Я...") {
                aboutMeTextView.text = "I am..."
            }
            eduProgramLabel.text = "Educational program"
            eduProgramTextField.placeholder = "Choose an educational program"
            dormLabel.text = "Dormitory"
            dormTextField.placeholder = "Choose a dormitory"
            stageOfEduLabel.text = "Stage of education"
            stageOfEduTextField.placeholder = "Choose a stage of education"
            campusLocationLabel.text = "Campus location"
            campusLocationTextField.placeholder = "Choose a campus location"
            genderLabel.text = "Gender"
            maleButton.setTitle("Male", for: .normal)
            femaleButton.setTitle("Female", for: .normal)
            birthdayLabel.text = "Birthday date"
            birthdayTextField.placeholder = "Choose a birthday date"
            if isProfileInfoEditing {
                bottomButtom.setTitle("Save", for: .normal)
            } else {
                bottomButtom.setTitle("Log out", for: .normal)
            }
            datePicker.locale = Locale(identifier: "en")
        } else {
            myDataLabel.text = "Мои данные"
            nameLabel.text = "Имя"
            nameTextFiled.placeholder = "Введите имя"
            surnameLabel.text = "Фамилия"
            surnameTextField.placeholder = "Введите фамилию"
            emailTextField.placeholder = "Введите почту"
            socialNetworkLabel.text = "Социальная сеть"
            socialNetworkTextField.placeholder = "t.me/ или vk.com/"
            aboutMeLabel.text = "Обо мне"
            canButton.setTitle("Могу", for: .normal)
            wantButton.setTitle("Хочу", for: .normal)
            if (aboutMeTextView.text == "I am...") {
                aboutMeTextView.text = "Я..."
            }
            eduProgramLabel.text = "Образовательная программа"
            eduProgramTextField.placeholder = "Выберите образовательную программу"
            dormLabel.text = "Общежитие"
            dormTextField.placeholder = "Выберите общежитие"
            stageOfEduLabel.text = "Ступень обучения"
            stageOfEduTextField.placeholder = "Выберите ступень обучения"
            campusLocationLabel.text = "Расположение корпуса"
            campusLocationTextField.placeholder = "Выберете расположение корпуса"
            genderLabel.text = "Пол"
            maleButton.setTitle("Мужской", for: .normal)
            femaleButton.setTitle("Женский", for: .normal)
            birthdayLabel.text = "Дата рождения"
            birthdayTextField.placeholder = "Выберете дату рождения"
            if isProfileInfoEditing {
                bottomButtom.setTitle("Сохранить", for: .normal)
            } else {
                bottomButtom.setTitle("Выйти из аккаунта", for: .normal)
            }
            datePicker.locale = Locale(identifier: "ru")
        }
    }
}
