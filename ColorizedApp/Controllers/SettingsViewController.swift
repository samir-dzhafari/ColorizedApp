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
    
        setupSliders()
        setupTextFields()
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
            redTextField.text = formatValue(sender.value)
        case greenSlider:
            greenTextField.text = formatValue(sender.value)
        default:
            blueTextField.text = formatValue(sender.value)
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
    private func setupSliders() {
        let ciColor = CIColor(color: color)
        
        redSlider.value = Float(ciColor.red)
        greenSlider.value = Float(ciColor.green)
        blueSlider.value = Float(ciColor.blue)
    }
    
    private func setupTextFields() {
        let ciColor = CIColor(color: color)
        
        redTextField.delegate = self
        greenTextField.delegate = self
        blueTextField.delegate = self

        redTextField.text = formatValue(Float(ciColor.red))
        greenTextField.text = formatValue(Float(ciColor.green))
        blueTextField.text = formatValue(Float(ciColor.blue))
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
            redSlider.value = value
        case greenTextField:
            greenSlider.value = value
        default:
            blueSlider.value = value
        }
        
        if let text = textField.text {
            textField.text = formatValue(Float(text) ?? 0)
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
