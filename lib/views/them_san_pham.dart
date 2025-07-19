import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luxe_silver_app/constant/app_color.dart';
import 'package:luxe_silver_app/constant/dieukien%20.dart';
import 'package:luxe_silver_app/controllers/product_controller.dart';
import 'package:luxe_silver_app/repository/product_repository.dart';
import 'package:luxe_silver_app/services/api_service.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Các controller cho các trường nhập liệu
  final TextEditingController nameController = TextEditingController();
  final TextEditingController accessoryController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int sizeFieldsKey = 0;
  List<Map<String, String>> sizeList = [
    {'size': '', 'quantity': '', 'price': '', 'donvi': 'mm'},
  ];
  final List<String> accessoryOptions = [
    'Dây chuyền',
    'Nhẫn',
    'Lắc tay',
    'Bông tai',
    'Lắc chân',
    'Mặt dây',
    'Nhẫn đôi',
    'Dây chuyền đôi',
    'Vòng tay đôi',
    'Bộ',
  ];
  String? selectedAccessory;

  bool isFreesize = false;

  String gender = 'Nữ';
  String type = 'Lẻ';
  String sizeUnit = 'mm';

  // Danh sách ảnh sản phẩm
  List<XFile> productImages = [];

  // Hàm chọn ảnh từ gallery
  Future<void> _pickImagesFromGallery() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        productImages.addAll(selectedImages);
      });
    }
  }

  // Hàm chụp ảnh từ camera
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        productImages.add(photo);
      });
    }
  }

  // Hàm xóa ảnh
  void _removeImage(int index) {
    setState(() {
      productImages.removeAt(index);
    });
  }

  // Hiển thị dialog chọn nguồn ảnh
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.alertDialog,
          title: const Text('Chọn nguồn ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProduct() async {
    // Nếu là Freesize, chuẩn hóa lại sizeList
    if (isFreesize) {
      String quantity = '';
      String price = '';
      if (sizeList.isNotEmpty) {
        quantity = sizeList[0]['quantity'] ?? '';
        price = sizeList[0]['price'] ?? '';
      }
      sizeList = [
        {
          'size': '0',
          'quantity': quantity,
          'price': price,
          'donvi': 'freesize',
        },
      ];
    }
    // Ánh xạ loại sang id_loai
    int idLoai = 1;
    if (type == 'Đôi') {
      idLoai = 2;
    } else if (type == 'Bộ') {
      idLoai = 3;
    }
    List<File> images = productImages.map((xfile) => File(xfile.path)).toList();

    final controller = ProductController(ProductRepository(ApiService()));
    final result = await controller.addProduct(
      tensp: nameController.text,
      gioitinh: gender,
      chatlieu: materialController.text,
      tenpk: accessoryController.text,
      idLoai: idLoai,
      mota: descriptionController.text,
      donvi: sizeUnit,
      sizes: sizeList,
      isFreesize: isFreesize,
      images: images,
    );
    print(result);
    print(jsonEncode(sizeList));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result ?? 'Có lỗi xảy ra')));

    //  reset form
    if (result != null && result.contains('thành công')) {
      setState(() {
        nameController.clear();
        accessoryController.clear();
        materialController.clear();
        descriptionController.clear();
        sizeList = [
          {'size': '', 'quantity': '', 'price': '', 'donvi': 'mm'},
        ];
        isFreesize = false;
        gender = 'Nữ';
        type = 'Lẻ';
        sizeUnit = 'mm';
        productImages.clear();
        sizeFieldsKey++;
      });
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thêm sản phẩm'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Phần tải ảnh sản phẩm
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ảnh sản phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Thêm ảnh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Hiển thị ảnh đã chọn
                    if (productImages.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(productImages[index].path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có ảnh nào',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Tên sản phẩm',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),
              // Phụ kiện
              DropdownButtonFormField<String>(
                value: selectedAccessory,
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Phụ kiện',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                items:
                    accessoryOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedAccessory = val;
                    accessoryController.text = val ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),
              // Chất liệu
              TextFormField(
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Chất liệu',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                controller: materialController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giới tính:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Radio<String>(
                            value: 'Nữ',
                            groupValue: gender,
                            onChanged: (val) => setState(() => gender = val!),
                          ),
                          const Text('Nữ'),
                        ],
                      ),
                      Column(
                        children: [
                          Radio<String>(
                            value: 'Nam',
                            groupValue: gender,
                            onChanged: (val) => setState(() => gender = val!),
                          ),
                          const Text('Nam'),
                        ],
                      ),
                      Column(
                        children: [
                          Radio<String>(
                            value: 'Unisex',
                            groupValue: gender,
                            onChanged: (val) => setState(() => gender = val!),
                          ),
                          const Text('Unisex'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Loại:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Radio<String>(
                            value: 'Lẻ',
                            groupValue: type,
                            onChanged: (val) => setState(() => type = val!),
                          ),
                          const Text('Lẻ'),
                        ],
                      ),
                      Column(
                        children: [
                          Radio<String>(
                            value: 'Đôi',
                            groupValue: type,
                            onChanged: (val) => setState(() => type = val!),
                          ),
                          const Text('Đôi'),
                        ],
                      ),
                      Column(
                        children: [
                          Radio<String>(
                            value: 'Bộ',
                            groupValue: type,
                            onChanged: (val) => setState(() => type = val!),
                          ),
                          const Text('Bộ'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isFreesize,
                    onChanged: (val) {
                      setState(() {
                        isFreesize = val!;
                        if (isFreesize) {
                          sizeList = [
                            {
                              'size': '',
                              'quantity': '',
                              'price': '',
                              'donvi': 'freesize',
                            },
                          ];
                        } else {
                          // Khi bỏ chọn Freesize, reset lại đơn vị cho tất cả size về 'mm'
                          for (var item in sizeList) {
                            item['donvi'] = 'mm';
                          }
                        }
                      });
                    },
                  ),
                  const Text('Freesize'),
                ],
              ),
              Column(
                key: ValueKey(sizeFieldsKey),
                children: [
                  ...sizeList.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Row(
                      children: [
                        // Size
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  text: 'Size',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            initialValue: isFreesize ? '' : entry.value['size'],
                            enabled: !isFreesize,
                            keyboardType: TextInputType.number,
                            onChanged: (val) => sizeList[idx]['size'] = val,
                            validator: (value) {
                              if (!isFreesize) {
                                return validator.notNegativeInt(value);
                              }
                              return null;
                            },
                          ),
                        ),
                        // Đơn vị
                        Expanded(
                          child:
                              isFreesize
                                  ? TextFormField(
                                    enabled: false,
                                    initialValue: 'freesize',
                                    decoration: const InputDecoration(
                                      labelText: 'Đơn vị',
                                    ),
                                  )
                                  : DropdownButtonFormField<String>(
                                    value: entry.value['donvi'] ?? 'mm',
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'mm',
                                        child: Text('mm'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'cm',
                                        child: Text('cm'),
                                      ),
                                    ],
                                    onChanged:
                                        (val) => setState(
                                          () => sizeList[idx]['donvi'] = val!,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Đơn vị',
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 8),
                        // Số lượng
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  text: 'SL',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            initialValue: entry.value['quantity'],
                            keyboardType: TextInputType.number,
                            onChanged: (val) => sizeList[idx]['quantity'] = val,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Không được để trống';
                              final n = int.tryParse(value);
                              if (n == null || n < 0)
                                return 'Chỉ nhập số nguyên không âm';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Giá
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  text: 'Giá',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              suffixText: 'VND',
                            ),
                            initialValue: entry.value['price'],
                            keyboardType: TextInputType.number,
                            onChanged: (val) => sizeList[idx]['price'] = val,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Không được để trống';
                              final n = int.tryParse(value);
                              if (n == null || n < 0)
                                return 'Chỉ nhập số nguyên không âm';
                              return null;
                            },
                          ),
                        ),
                        if (!isFreesize)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                sizeList.removeAt(idx);
                              });
                            },
                          ),
                      ],
                    );
                  }).toList(),
                  if (!isFreesize)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          sizeList.add({
                            'size': '',
                            'quantity': '',
                            'price': '',
                          });
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm size'),
                    ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Mô tả',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                controller: descriptionController,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveProduct();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Lưu sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
