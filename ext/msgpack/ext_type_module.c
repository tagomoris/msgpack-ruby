


static inline VALUE
w2v(wideval_t w)
{
#if WIDEVALUE_IS_WIDER
    if (FIXWV_P(w))
        return INT64toNUM(FIXWV2WINT(w));
    return (VALUE)WIDEVAL_GET(w);
#else
    return WIDEVAL_GET(w);
#endif
}       

#define wmulquoll(x,y,z) (((y) == (z)) ? (x) : wquo(wmul((x),WINT2WV(y)),WINT2WV(z)))

static wideval_t
wmod(wideval_t wx, wideval_t wy)
{   
#if WIDEVALUE_IS_WIDER
    wideval_t r, dmy;
    if (wdivmod0(wx, wy, &dmy, &r)) return r;
#endif
    return v2w(modv(w2v(wx), w2v(wy)));
}


static VALUE ExtType_time_to_msgpack_ext(VALUE unused_obj, VALUE time)
{
    struct time_object *tobj;

    GetTimeval(time, tobj);
    VALUE epoch = w2v(wdiv(tobj->timew, WINT2FIXWV(TIME_SCALE))); // time_to_i
    VALUE nano = rb_to_int(w2v(wmulquoll(wmod(tobj->timew, WINT2WV(TIME_SCALE)), 1000000000, TIME_SCALE))); // time_nsec
    uint nsec = FIX2UINT(nano);
    // uint32?
    if (nsec == 0 && 
}

void MessagePack_ExtType_module_initialize(VALUE mMessagePack)
{
    msgpack_ext_type_static_init();

    cMessagePack_ExtType = rb_define_class_under(mMessagePack, "ExtType");

    rb_define_module_function(cMessagePack_ExtType, "time_to_msgpack_ext", ExtType_time_to_msgpack_ext, 1);
    rb_define_moduel_function(cMessagePack_ExtType, "time_from_msgpack_ext", ExtType_time_from_msgpack_ext, 1);
}
