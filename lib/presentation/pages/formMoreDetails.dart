import 'dart:convert';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/samplesResponse.dart' show SamplesResponse;
import 'package:aw_app/models/WaterSourceTypeModel.dart' show WaterSourceType;
import 'package:aw_app/presentation/pages/InsertSamplePage.dart';
import 'package:aw_app/presentation/pages/ViewSamplePage.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:aw_app/provider/samplesProvider.dart';
import 'package:aw_app/server/apis.dart';
import 'package:intl/intl.dart';

class FormMoreDetails extends StatelessWidget {
  final int rfid;

  const FormMoreDetails({required this.rfid, super.key});

  // Get color based on status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Colors.green.shade400;
      case 'ready':
        return Colors.blue.shade400;
      case 'pending':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  // Format datetime nicely
  String formatDateTime(String? datetime) {
    if (datetime == null || datetime.isEmpty) return 'Not Found';
    try {
      final dt = DateTime.parse(datetime).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return datetime; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final samplesProvider = context.watch<SamplesProvider>();
    final authProvider = context.read<AuthProvider>();
    final samplesList = samplesProvider.samplesList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 40,
            tooltip: 'Add Sample',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsertSamplePage(rfid: rfid),
                ),
              );
            },
          ),
        ],
        // centerTitle: true,
        elevation: 4,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "Form Sample Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Review collected samples",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: samplesProvider.isSampleLoading
          ? const Center(child: CircularProgressIndicator())
          : samplesList.isEmpty
          ? const Center(child: Text("No samples found"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: samplesList.length,
              itemBuilder: (context, index) {
                final sample = samplesList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.blueGrey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: No# and Status + SampleID
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "No# ${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(sample.sampleStatus),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sample.sampleStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Sample ID: ${sample.sampleID}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AWColors.colorDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Location
                        Text(
                          sample.location,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Water Source & Batch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "WaterSource: ${WaterSourceType.getNameById(sample.waterSourceTypeID)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Batch: ${sample.batchNo}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Sample DateTime
                        Text(
                          "SampleDatetime: ${formatDateTime(sample.sampleDatetime)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),

                        // Analysis Types (async)
                        FutureBuilder<http.Response>(
                          future: Api.get.getAnalysisType(
                            authProvider.token!,
                            sample.sampleID,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                "Analysis Required: Loading...",
                                style: TextStyle(fontSize: 14),
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                "Analysis Required: Error",
                                style: TextStyle(fontSize: 14),
                              );
                            } else if (snapshot.hasData) {
                              final data = jsonDecode(snapshot.data!.body);
                              final analysis = (data as List)
                                  .map((e) => e['AnalysisTypeDesc'])
                                  .join(', ');
                              return Text(
                                "Analysis Required: $analysis",
                                style: const TextStyle(fontSize: 14),
                              );
                            } else {
                              return const Text(
                                "Analysis Required: N/A",
                                style: TextStyle(fontSize: 14),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
