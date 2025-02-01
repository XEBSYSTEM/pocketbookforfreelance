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
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: onAgentRegisterPressed,
                child: const Text(
                  '登録',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // エンド企業
        Row(
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
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: onEndCompanyRegisterPressed,
                child: const Text(
                  '登録',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
