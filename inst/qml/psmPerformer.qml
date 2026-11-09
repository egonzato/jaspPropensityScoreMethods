//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

//JASP power


import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP.Widgets
import JASP
import "./common/ui" as UI

Form
{

  info: qsTr("Propensity score matching pairs treated and untreated units with similar propensity scores (or covariate values), creating a matched sample in which the confounders are balanced between the two groups. The output shows covariate balance before and after matching, the sample sizes, a love plot and the distribution of the covariates in both groups.")

  Text
  {
      text: qsTr("Variables in dataset")
  }

  VariablesForm
	{
		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
		infoLabel: qsTr("Input")
		AvailableVariablesList{  name: "allVariablesList" }
		AssignedVariablesList {  name: "treatment"; title: qsTr("Treatment"); allowedColumns: ["nominal"]; info: qsTr("Binary variable indicating whether a unit received the treatment (1) or not (0).") ; singleVariable: true; minLevels: 2}
		AssignedVariablesList {  name: "confounders"; title: qsTr("Confounders"); allowedColumns: ["scale","nominal","ordinal"]; info: qsTr("Variables that affect both treatment assignment and the outcome. They are used to estimate the propensity score and to assess balance.")}
	}
	// treatment formula
	Group {
		Layout.columnSpan: 2
		title: qsTr("Non-linear specification of the treatment model (overrides confounders specification)")
		info: qsTr("Optional R formula for the treatment model, e.g. treatment ~ age + I(age^2) + sex. When filled in, it is used instead of the confounders listed above.")

		TextArea {
			name: "customFormula"
			Layout.preferredWidth: 500*jaspTheme.uiScale
			Layout.preferredHeight: 100*jaspTheme.uiScale
			textType: JASP.TextTypeRcode
			showLineNumber: true
		}

		Text {
			text: qsTr("ℹ️ Available variables: ") + "'" + allVariablesList.valueNames.join("', '") + "'"
			font.pointSize: 9
			color: jaspTheme.moderateGray
			wrapMode: Text.WordWrap
		}
	}	
// matching specifics
	Group
	{
		title: qsTr("Matching specifics")

		CheckBox
		{
			name: "replacement"
			label: qsTr("With replacement")
			info: qsTr("When checked, an untreated unit can be matched to more than one treated unit. When unchecked, each untreated unit is used at most once.")
			checked: false
		}

		DropDown
		{
			info: qsTr("Distance measure used to decide how similar two units are: the estimated probability of treatment, its logit, or the Mahalanobis distance computed on the confounders.")

			name: "distance_dropdown"
			label: qsTr("Distance")
			values: ["Probability", "Logit", "Mahalanobis"]
		}
		DropDown
		{
			info: qsTr("Matching algorithm. 'Nearest' matches each treated unit in turn to the closest available untreated unit(s). 'Optimal' finds the matching that minimises the total distance across all pairs.")

			id: methodDropdown
			name: "method_dropdown"
			label: qsTr("Method")
			values: ["Nearest", "Optimal"]
		}
		IntegerField
		{
			info: qsTr("Number of untreated units to match to each treated unit.")

			name: "ratio"
			label: qsTr("Ratio")   

			min: 1
			defaultValue: 1
			fieldWidth: 50
			max: 1000
		}
	
	Group {

		info: qsTr("Maximum allowed distance between matched units, expressed in standard deviations of the propensity score. With the Mahalanobis distance, a propensity score is estimated only to apply the caliper. Available only when Method is set to 'Nearest'.")

		title: qsTr("Caliper")
		enabled: methodDropdown.currentValue === "Nearest"

		CheckBox {
			id: caliperEnabled
			name: "caliperEnabled"
			label: qsTr("Use caliper")
			checked: false
		}

		DoubleField {
			name: "caliper"
			enabled: caliperEnabled.checked
			label: qsTr("Caliper width")
			defaultValue: 0.1
			fieldWidth: 50
			min: 0
			max: 1
			decimals: 5
		}
	}
}

	// Group
	// {
	// 	title: qsTr("Covariate balance")

	// 	CheckBox
	// 	{
	// 		info: qsTr("This tick mark defines whether the summary of the proedure will be displayed or not")
	// 		name: "distance"
	// 		label: qsTr("Summary distance measures")
	// 		checked: true
	// 	}
	// 	CheckBox
	// 	{
	// 		info: qsTr("Display love plot")
	// 		name: "love"
	// 		label: qsTr("Love plot")
	// 		checked: true 
	// 	}
	// 	CheckBox
	// 	{
	// 		info: qsTr("Display distributions of covariates in treated and untreated, before and after matching")
	// 		name: "densitites"
	// 		label: qsTr("Density plot")
	// 		checked: true
	// 	}
	// }
Group {
    title: qsTr("Plot colors")

    Column {
        spacing: 6

        TextField {
            name: "untreatedColor"
            label: qsTr("Untreated")
            defaultValue: "#FF3300"
            fieldWidth: 70
        }

        TextField {
            name: "treatedColor"
            label: qsTr("Treated")
            defaultValue: "#0099FF"
            fieldWidth: 70
        }

        DoubleField {
            name: "opacity"
            label: qsTr("Opacity")
            defaultValue: 0.7
            min: 0
            max: 1
            decimals: 2
            fieldWidth: 50
        }
    }
}
Group
{
    title: qsTr("Export")

    FileSelector
    {
        name: "saveDatasetPath"
        label: qsTr("Save matched dataset as")
        filter: "*.csv"
        save: true
        info: qsTr("Saves the matched units with all dataset columns, plus the matching weights, subclass and distance (CSV).")
        fieldWidth: 200 * jaspTheme.uiScale
    }
}
}
