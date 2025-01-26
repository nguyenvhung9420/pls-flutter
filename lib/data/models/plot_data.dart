class PlotData {
  List<String>? plotData;

  PlotData({
    this.plotData,
  });

  factory PlotData.fromJson(Map<String, dynamic> json) => PlotData(
        plotData: json["plot_data"] == null ? [] : List<String>.from(json["plot_data"]!.map((x) => x.toString())),
      );
}
