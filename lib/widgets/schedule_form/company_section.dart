import 'package:flutter/material.dart';
import '../../models/schedule_form_data.dart';

class CompanySection extends StatelessWidget {
  final ScheduleFormData formData;
  final List<Map<String, dynamic>> agents;
  final List<Map<String, dynamic>> endCompanies;
  final ValueChanged<String?> onAgentChanged;
  final ValueChanged<String?> onEndCompanyChanged;

  const CompanySection({
    super.key,
    required this.formData,
    required this.agents,
    required this.endCompanies,
    required this.onAgentChanged,
    required this.onEndCompanyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // エージェント
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'エージェント',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          value: formData.agentId,
          items: agents
              .map((agent) => DropdownMenuItem(
                    value: agent['id'].toString(),
                    child: Text(
                      agent['company_name'],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ))
              .toList(),
          onChanged: onAgentChanged,
        ),
        const SizedBox(height: 16),

        // エンド企業
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'エンド企業',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          value: formData.endCompanyId,
          items: endCompanies
              .map((company) => DropdownMenuItem(
                    value: company['id'].toString(),
                    child: Text(
                      company['company_name'],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ))
              .toList(),
          onChanged: onEndCompanyChanged,
        ),
      ],
    );
  }
}
