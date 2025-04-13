CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- إنشاء جدول الشركات
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    commercial_record VARCHAR(100),
    tax_number VARCHAR(100),
    logo_url TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إضافة التعليقات التوضيحية لجدول الشركات
COMMENT ON TABLE companies IS 'جدول الشركات الرئيسية في النظام';
COMMENT ON COLUMN companies.id IS 'المعرف الفريد للشركة';
COMMENT ON COLUMN companies.name IS 'اسم الشركة';
COMMENT ON COLUMN companies.commercial_record IS 'رقم السجل التجاري';
COMMENT ON COLUMN companies.tax_number IS 'الرقم الضريبي';
COMMENT ON COLUMN companies.logo_url IS 'رابط شعار الشركة';
COMMENT ON COLUMN companies.status IS 'حالة الشركة (نشط، متوقف، محذوف)';
COMMENT ON COLUMN companies.created_at IS 'تاريخ إنشاء السجل';
COMMENT ON COLUMN companies.updated_at IS 'تاريخ آخر تحديث';

-- إنشاء جدول العناوين
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    street VARCHAR(255),
    building_no VARCHAR(50),
    postal_code VARCHAR(20),
    additional_details TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إضافة التعليقات التوضيحية لجدول العناوين
COMMENT ON TABLE addresses IS 'جدول العناوين المستخدمة في النظام';
COMMENT ON COLUMN addresses.id IS 'المعرف الفريد للعنوان';
COMMENT ON COLUMN addresses.country IS 'اسم الدولة';
COMMENT ON COLUMN addresses.city IS 'اسم المدينة';
COMMENT ON COLUMN addresses.district IS 'اسم الحي';
COMMENT ON COLUMN addresses.street IS 'اسم الشارع';
COMMENT ON COLUMN addresses.building_no IS 'رقم المبنى';
COMMENT ON COLUMN addresses.postal_code IS 'الرمز البريدي';
COMMENT ON COLUMN addresses.additional_details IS 'تفاصيل إضافية للعنوان';
COMMENT ON COLUMN addresses.latitude IS 'خط العرض';
COMMENT ON COLUMN addresses.longitude IS 'خط الطول';

-- إنشاء جدول الفروع
CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    phone VARCHAR(50),
    email VARCHAR(255),
    is_main_branch BOOLEAN DEFAULT false,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إضافة التعليقات التوضيحية لجدول الفروع
COMMENT ON TABLE branches IS 'جدول فروع الشركات';
COMMENT ON COLUMN branches.id IS 'المعرف الفريد للفرع';
COMMENT ON COLUMN branches.company_id IS 'معرف الشركة التابع لها الفرع';
COMMENT ON COLUMN branches.name IS 'اسم الفرع';
COMMENT ON COLUMN branches.address_id IS 'معرف عنوان الفرع';
COMMENT ON COLUMN branches.phone IS 'رقم هاتف الفرع';
COMMENT ON COLUMN branches.email IS 'البريد الإلكتروني للفرع';
COMMENT ON COLUMN branches.is_main_branch IS 'هل هو الفرع الرئيسي';
COMMENT ON COLUMN branches.status IS 'حالة الفرع (نشط، متوقف، محذوف)';

-- إنشاء جدول سجلات الاشتراكات
CREATE TABLE subscription_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    subscription_type VARCHAR(50) NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إضافة التعليقات التوضيحية لجدول سجلات الاشتراكات
COMMENT ON TABLE subscription_logs IS 'جدول سجلات اشتراكات الشركات';
COMMENT ON COLUMN subscription_logs.id IS 'المعرف الفريد لسجل الاشتراك';
COMMENT ON COLUMN subscription_logs.company_id IS 'معرف الشركة المشتركة';
COMMENT ON COLUMN subscription_logs.subscription_type IS 'نوع الاشتراك';
COMMENT ON COLUMN subscription_logs.start_date IS 'تاريخ بداية الاشتراك';
COMMENT ON COLUMN subscription_logs.end_date IS 'تاريخ نهاية الاشتراك';
COMMENT ON COLUMN subscription_logs.amount IS 'قيمة الاشتراك';
COMMENT ON COLUMN subscription_logs.payment_status IS 'حالة الدفع';
COMMENT ON COLUMN subscription_logs.payment_method IS 'طريقة الدفع';
COMMENT ON COLUMN subscription_logs.transaction_id IS 'رقم العملية';
COMMENT ON COLUMN subscription_logs.notes IS 'ملاحظات إضافية';

-- إنشاء الفهارس للتحسين الأداء
CREATE INDEX idx_companies_status ON companies(status);
CREATE INDEX idx_branches_company_id ON branches(company_id);
CREATE INDEX idx_branches_address_id ON branches(address_id);
CREATE INDEX idx_subscription_logs_company_id ON subscription_logs(company_id);
CREATE INDEX idx_subscription_logs_dates ON subscription_logs(start_date, end_date);

-- إنشاء Trigger لتحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_branches_updated_at
    BEFORE UPDATE ON branches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at
    BEFORE UPDATE ON addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_logs_updated_at
    BEFORE UPDATE ON subscription_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();