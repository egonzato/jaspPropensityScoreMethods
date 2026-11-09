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
import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP.Widgets
import JASP
import "./common/ui" as UI

Form
{

  info: qsTr("Inverse probability of treatment weighting gives each unit a weight equal to the inverse of its estimated probability of receiving the treatment it actually received. In the weighted sample the confounders are balanced between treated and untreated units. The output shows a summary of the weights, standardised mean differences, the effective sample size, covariate distributions, a love plot and the propensity score overlap.")

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
	
	Group{
	title: qsTr("Weighting specifics")

		CheckBox
		{
			name: "stabilize"
			label: qsTr("Stabilize weights")
			info: qsTr("Uses the marginal probability of treatment as the numerator of the weights instead of 1. Stabilized weights have a mean close to 1 and lower variance.")
			checked: false
		}
	}
	Group{
		title: qsTr("Truncating weights")
		CheckBox{
			
				id: truncateEnabled
				name: "truncateEnabled"
				label: qsTr("Truncate")
				info: qsTr("Limits extreme weights by setting weights below the lower percentile and above the upper percentile to those percentile values.")
				checked: false
		}	
		DoubleField {
			name: "truncate"
			enabled: truncateEnabled.checked
			label: qsTr("Percentile to truncate")
			info: qsTr("Percentile used for truncation, e.g. 0.01 truncates weights at the 1st and 99th percentiles.")
			defaultValue: 0.01
			fieldWidth: 50
			max: 1
			decimals: 5
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
        label: qsTr("Save weighted dataset as")
        filter: "*.csv"
        save: true
        fieldWidth: 200 * jaspTheme.uiScale
        info: qsTr("Saves the dataset with the IPTW weights added as a column (CSV)")
    }
}

}
