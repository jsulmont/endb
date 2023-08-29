use serde::{Deserialize, Serialize};

#[derive(Clone, PartialEq, Debug, Serialize, Deserialize)]
#[repr(C)]
pub enum Keyword {
    Select,
    From,
    Where,
    GroupBy,
    Having,
    OrderBy,
    Lt,
    Le,
    Gt,
    Ge,
    Eq,
    Ne,
    Is,
    In,
    InQuery,
    Between,
    Like,
    Case,
    Exists,
    ScalarSubquery,
    Else,
    Plus,
    Minus,
    Mul,
    Div,
    Mod,
    Lsh,
    Rsh,
    And,
    Or,
    Not,
    Function,
    AggregateFunction,
    Count,
    CountStar,
    Avg,
    Sum,
    Min,
    Max,
    Total,
    GroupConcat,
    Cast,
    Asc,
    Desc,
    Distinct,
    All,
    True,
    False,
    Null,
    Limit,
    Offset,
    Join,
    Type,
    Left,
    Inner,
    On,
    Except,
    Intersect,
    Union,
    UnionAll,
    Values,
    Insert,
    ColumnNames,
    Delete,
    Update,
    CreateIndex,
    DropIndex,
    CreateView,
    DropView,
    IfExists,
    CreateTable,
    DropTable,
    MultipleStatements,
    Date,
    Time,
    Timestamp,
    Array,
    Object,
    Access,
    AsOf,
    With,
    ArrayAgg,
    ObjectAgg,
    ArrayQuery,
    Unnest,
    WithOrdinality,
    Objects,
    Parameter,
    Concat,
    ShorthandProperty,
    SpreadProperty,
    ComputedProperty,
    Duration,
    CurrentDate,
    CurrentTime,
    CurrentTimestamp,
    Unset,
    Recursive,
    Overlaps,
    Contains,
    Precedes,
    Succedes,
    ImmediatelyPrecedes,
    ImmediatelySuccedes,
    Year,
    Month,
    Day,
    Hour,
    Minute,
    Second,
    Interval,
    OnConflict,
    Blob,
    Glob,
    Regexp,
    Patch,
    Match,
    BitNot,
    BitAnd,
    BitOr,
    Hash,
    Path,
}

#[derive(Clone, PartialEq, Debug, Serialize, Deserialize)]
#[repr(C)]
pub enum Ast {
    List(Vec<Ast>),
    KW(Keyword),
    Integer(i128),
    Float(f64),
    Id { start: i32, end: i32 },
    String { start: i32, end: i32 },
}
