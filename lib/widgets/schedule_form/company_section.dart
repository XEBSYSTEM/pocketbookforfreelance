import 'package:flutter/material.dart';
import '../../models/schedule_form_data.dart';

class CompanySection extends StatelessWidget {
  final ScheduleFormData formData;
  final List<Map<String, dynamic>> agents;
  final List<Map<String, dynamic>> endCompanies;
  final ValueChanged<String?> onAgentChanged;
  final ValueChanged<String?> onEndCompanyChanged;
  final VoidCallback onAgentRegisterPressed;
  final VoidCallback onEndCompanyRegisterPressed;

  const CompanySection({
    super.key,
    required this.formData,
    required this.agents,
    required this.endCompanies,
    required this.onAgentChanged,
    required this.onEndCompanyChanged,
    required this.onAgentRegisterPressed,
    required this.onEndCompanyRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // エージェント
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
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
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                style: const TextStyle(color: Colors.black),
                value: formData.agentId,
                items: agents
                    .map((agent) => DropdownMenuItem(
                          value: agent['id'].toString(),
                          child: Text(
                            agent['company_name'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: onAgentChanged,
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: ElevatedButton(
                onPressed: onAgentRegisterPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  '登録',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // エンド企業
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
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
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                style: const TextStyle(color: Colors.black),
                value: formData.endCompanyId,
                items: endCompanies
                    .map((company) => DropdownMenuItem(
                          value: company['id'].toString(),
                          child: Text(
                            company['company_name'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: onEndCompanyChanged,
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: ElevatedButton(
                onPressed: onEndCompanyRegisterPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  '登録',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
