//
//  SettingsViewController.swift
//  ColorizedApp
//
//  Created by Самир Джафари on 19.10.2023.
//

import UIKit

protocol SettingsViewControllerDelegate: NSObjectProtocol {
    func doneButtonPressed(_ color: UIColor)
}

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var colorPresenterView: UIView!
    
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blueTextField: UITextField!
    
    weak var deligate: SettingsViewControllerDelegate!
    
    var color: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pallete = getPallete(color)
        
        setupLabels(pallete: pallete)
        setupSliders(pallete: pallete)
        setupTextFields(pallete: pallete)
        setupKeyboardToolBar()
        
        colorPresenterView.backgroundColor = color
    }
    
    override func viewDidLayoutSubviews() {
        colorPresenterView.layer.cornerRadius = 12
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func colorSliderChange(_ sender: UISlider) {
        switch sender {
        case redSlider:
            updateUI(label: redLabel, textField: redTextField, sender.value)
        case greenSlider:
            updateUI(label: greenLabel, textField: greenTextField, sender.value)
        default:
            updateUI(label: blueLabel, textField: blueTextField, sender.value)
        }
        
        updateColorViewPresenter()
    }
    
    @IBAction func doneButtonTapped() {
        let uiColor = UIColor(
            red: CGFloat(redSlider.value),
            green: CGFloat(greenSlider.value),
            blue: CGFloat(blueSlider.value),
            alpha: 1
        )
        
        deligate.doneButtonPressed(uiColor)
        
        dismiss(animated: true)
    }
}

// MARK: - Setup methods

extension SettingsViewController {
    
    private func setupLabels(pallete: Pallete) {
        redLabel.text = formatValue(pallete.red)
        greenLabel.text = formatValue(pallete.green)
        blueLabel.text = formatValue(pallete.blue)
    }
    
    private func setupSliders(pallete: Pallete) {
        redSlider.value = pallete.red
        greenSlider.value = pallete.green
        blueSlider.value = pallete.blue
    }
    
    private func setupTextFields(pallete: Pallete) {
        redTextField.delegate = self
        greenTextField.delegate = self
        blueTextField.delegate = self

        redTextField.text = formatValue(pallete.red)
        greenTextField.text = formatValue(pallete.green)
        blueTextField.text = formatValue(pallete.blue)
    }
    
    private func setupKeyboardToolBar() {
        let toolbar = UIToolbar()
        
        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneKeyboardButtonAction)
        )
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.sizeToFit()
        toolbar.setItems([flexibleSpace, doneBarButton], animated: false)
        
        redTextField.inputAccessoryView = toolbar
        greenTextField.inputAccessoryView = toolbar
        blueTextField.inputAccessoryView = toolbar
    }
    
    @objc private func doneKeyboardButtonAction() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let value = Float(textField.text ?? "") else {
            showAlert()
            return false
        }
        
        if (0...1) ~= value {
            return true
        }
        
        showAlert()
        return false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let value = Float(textField.text ?? "") else {
            return
        }
        
        switch textField {
        case redTextField:
            updateUI(label: redLabel, slider: redSlider, value)
        case greenTextField:
            updateUI(label: greenLabel, slider: greenSlider, value)
        default:
            updateUI(label: blueLabel, slider: blueSlider, value)
        }
        
        if textField.text != nil {
            textField.text = formatValue(value)
        }
     
        
        updateColorViewPresenter()
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string == "," {
            textField.text = textField.text! + "."
            return false
        }
        
        if let text = textField.text, string.count != 0 {
            return text.count < 4
        }
        
        return true
    }
    
}

// MARK: - UI methods

extension SettingsViewController {
    private func updateColorViewPresenter() {
        colorPresenterView.backgroundColor = UIColor(
            red: CGFloat(redSlider.value),
            green: CGFloat(greenSlider.value),
            blue: CGFloat(blueSlider.value),
            alpha: 1
        )
    }
    
    // Можно было бы дженерики заюзать, но мы не изучали, либо тип Any, но я хотел сделать типизацию
    
    private func updateUI(label: UILabel, textField: UITextField, _ value: Float) {
        let value = formatValue(value)
        
        label.text = value
        textField.text = value
    }
    
    private func updateUI(label: UILabel, slider: UISlider, _ value: Float) {
        let stringValue = formatValue(value)
        
        label.text = stringValue
        slider.value = value
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Wrong format!",
            message: "Please enter correct value",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - Helper methods

extension SettingsViewController {
    
    private typealias Pallete = (red: Float, green: Float, blue: Float)
    
    private func getPallete(_ color: UIColor) -> Pallete {
        let ciColor = CIColor(color: color)
        return (Float(ciColor.red), Float(ciColor.green), Float(ciColor.blue))
    }
    
    private func formatValue(_ number: Float) -> String {
        let numberFormatter = NumberFormatter()

        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.decimalSeparator = "."

        if let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) {
            return formattedNumber
        }
        
        return ""
    }
}
