import QtQuick
import JASP.Module

Description
{
	name		: "jaspPropensityScoreMethods"
	title		: qsTr("Propensity Score Methods")
	description	: qsTr("Causal inference with propensity score methods: matching and inverse probability of treatment weighting.")
	version		: "0.1"
	author		: "egonzato"
	maintainer	: "egonzato <https://github.com/egonzato>"
	website		: "https://github.com/egonzato/jaspPropensityScoreMethods"
	license		: "GPL (>= 2)"
	icon		: "conf.png"
	preloadData: true
	requiresData: true

	GroupTitle
	{
		title:	qsTr("Methods")
	}

	Analysis
	{
		title: qsTr("Propensity Score Matching")
		menu: qsTr("Propensity Score Matching")
		func: "matching"
		qml: "psmPerformer.qml"
		requiresData: true
	}

	Analysis
	{
		title: qsTr("Inverse Probability of Treatment Weighting")
		menu: qsTr("Inverse Probability of Treatment Weighting")
		func: "iptw"
		qml: "iptwPerformer.qml"
		requiresData: true
	}
}
