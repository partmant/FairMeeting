import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModifyButtonRow extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onAdd;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  const ModifyButtonRow({
    super.key,
    required this.isEditing,
    required this.onAdd,
    required this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 취소 버튼
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('취소', style: TextStyle(color: Colors.black)),
          onPressed: onCancel,
        ),
        const SizedBox(width: 8),

        // 삭제 버튼 (수정 모드일 때만)
        if (isEditing && onDelete != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                  backgroundColor: Colors.white,
                  child: SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('삭제',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text('이 약속을 삭제하시겠습니까?'),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('취소',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onDelete!();
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('확인',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        const Spacer(),

        // 추가/수정 버튼
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9C189),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(isEditing ? '수정' : '추가',
                style: const TextStyle(color: Colors.white)),
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}
